/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* this implements a sensors hardware library for the Android emulator.
 * the following code should be built as a shared library that will be
 * placed into /system/lib/hw/sensors.goldfish.so
 *
 * it will be loaded by the code in hardware/libhardware/hardware.c
 * which is itself called from com_android_server_SensorService.cpp
 */

#define  SENSORS_SERVICE_NAME "sensors"

#define LOG_TAG "Dummy_Sensors"

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <log/log.h>
#include <cutils/sockets.h>
#include <hardware/sensors.h>
#include <pthread.h>

#if 0
#define  D(...)  ALOGD(__VA_ARGS__)
#else
#define  D(...)  ((void)0)
#endif

#define  E(...)  ALOGE(__VA_ARGS__)

/** SENSOR IDS AND NAMES
 **/

#define MAX_NUM_SENSORS 8

#define SUPPORTED_SENSORS  ((1<<MAX_NUM_SENSORS)-1)

#define  ID_BASE           SENSORS_HANDLE_BASE
#define  ID_ACCELERATION   (ID_BASE+0)
#define  ID_MAGNETIC_FIELD (ID_BASE+1)
#define  ID_ORIENTATION    (ID_BASE+2)
#define  ID_TEMPERATURE    (ID_BASE+3)
#define  ID_PROXIMITY      (ID_BASE+4)
#define  ID_LIGHT          (ID_BASE+5)
#define  ID_PRESSURE       (ID_BASE+6)
#define  ID_HUMIDITY       (ID_BASE+7)

#define  SENSORS_ACCELERATION    (1 << ID_ACCELERATION)
#define  SENSORS_MAGNETIC_FIELD  (1 << ID_MAGNETIC_FIELD)
#define  SENSORS_ORIENTATION     (1 << ID_ORIENTATION)
#define  SENSORS_TEMPERATURE     (1 << ID_TEMPERATURE)
#define  SENSORS_PROXIMITY       (1 << ID_PROXIMITY)
#define  SENSORS_LIGHT           (1 << ID_LIGHT)
#define  SENSORS_PRESSURE        (1 << ID_PRESSURE)
#define  SENSORS_HUMIDITY        (1 << ID_HUMIDITY)

#define  ID_CHECK(x)  ((unsigned)((x) - ID_BASE) < MAX_NUM_SENSORS)

#define  SENSORS_LIST  \
    SENSOR_(ACCELERATION,"acceleration") \
    SENSOR_(MAGNETIC_FIELD,"magnetic-field") \
    SENSOR_(ORIENTATION,"orientation") \
    SENSOR_(TEMPERATURE,"temperature") \
    SENSOR_(PROXIMITY,"proximity") \
    SENSOR_(LIGHT, "light") \
    SENSOR_(PRESSURE, "pressure") \
    SENSOR_(HUMIDITY, "humidity")

static const struct {
    const char*  name;
    int          id; } _sensorIds[MAX_NUM_SENSORS] =
{
#define SENSOR_(x,y)  { y, ID_##x },
    SENSORS_LIST
#undef  SENSOR_
};

static const char*
_sensorIdToName( int  id )
{
    int  nn;
    for (nn = 0; nn < MAX_NUM_SENSORS; nn++)
        if (id == _sensorIds[nn].id)
            return _sensorIds[nn].name;
    return "<UNKNOWN>";
}

static int
_sensorIdFromName( const char*  name )
{
    int  nn;

    if (name == NULL)
        return -1;

    for (nn = 0; nn < MAX_NUM_SENSORS; nn++)
        if (!strcmp(name, _sensorIds[nn].name))
            return _sensorIds[nn].id;

    return -1;
}

/* return the current time in nanoseconds */
static int64_t now_ns(void) {
    struct timespec  ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000000 + ts.tv_nsec;
}

/** SENSORS POLL DEVICE
 **
 ** This one is used to read sensor data from the hardware.
 ** We implement this by simply reading the data from the
 ** emulator through the QEMUD channel.
 **/

typedef struct SensorDevice {
    struct sensors_poll_device_1  device;
    sensors_event_t               sensors[MAX_NUM_SENSORS];
    uint32_t                      pendingSensors;
    int64_t                       timeStart;
    int64_t                       timeOffset;
    uint32_t                      active_sensors;
    int                           fd;
    pthread_mutex_t               lock;
} SensorDevice;

/* Grab the file descriptor to the emulator's sensors service pipe.
 * This function returns a file descriptor on success, or -errno on
 * failure, and assumes the SensorDevice instance's lock is held.
 *
 * This is needed because set_delay(), poll() and activate() can be called
 * from different threads, and poll() is blocking.
 *
 * 1) On a first thread, de-activate() all sensors first, then call poll(),
 *    which results in the thread blocking.
 *
 * 2) On a second thread, slightly later, call set_delay() then activate()
 *    to enable the acceleration sensor.
 *
 * The system expects this to unblock the first thread which will receive
 * new sensor events after the activate() call in 2).
 *
 * This cannot work if both threads don't use the same connection.
 *
 * TODO(digit): This protocol is brittle, implement another control channel
 *              for set_delay()/activate()/batch() when supporting HAL 1.3
 */
static int sensor_device_get_fd_locked(SensorDevice* dev) {
    /* Create connection to service on first call */
    if (dev->fd < 0) {
	    int ret = -errno;
	    E("%s: Could not open connection to service: %s", __FUNCTION__,
	    		    strerror(-ret));
	    return ret;
    }
    return dev->fd;
}

/* Pick up one pending sensor event. On success, this returns the sensor
 * id, and sets |*event| accordingly. On failure, i.e. if there are no
 * pending events, return -EINVAL.
 *
 * Note: The device's lock must be acquired.
 */
static int sensor_device_pick_pending_event_locked(SensorDevice* d,
                                                   sensors_event_t*  event)
{
    uint32_t mask = SUPPORTED_SENSORS & d->pendingSensors;

    if (mask) {
        uint32_t i = 31 - __builtin_clz(mask);

	pthread_mutex_lock(&d->lock);
        d->pendingSensors &= ~(1U << i);
        *event = d->sensors[i];
        event->sensor = i;
        event->version = sizeof(*event);
	pthread_mutex_unlock(&d->lock);
        D("%s: %d [%f, %f, %f]", __FUNCTION__,
                i,
                event->data[0],
                event->data[1],
                event->data[2]);
        return i;
    }
    E("No sensor to return!!! pendingSensors=0x%08x", d->pendingSensors);
    // we may end-up in a busy loop, slow things down, just in case.
    usleep(1000);
    return -EINVAL;
}

static int sensor_device_close(struct hw_device_t* dev0)
{
    SensorDevice* dev = (void*)dev0;
    // Assume that there are no other threads blocked on poll()
    if (dev->fd >= 0) {
        close(dev->fd);
        dev->fd = -1;
    }
    pthread_mutex_destroy(&dev->lock);
    free(dev);
    return 0;
}

/* Return an array of sensor data. This function blocks until there is sensor
 * related events to report. On success, it will write the events into the
 * |data| array, which contains |count| items. The function returns the number
 * of events written into the array, which shall never be greater than |count|.
 * On error, return -errno code.
 *
 * Note that according to the sensor HAL [1], it shall never return 0!
 *
 * [1] http://source.android.com/devices/sensors/hal-interface.html
 */
static int sensor_device_poll(struct sensors_poll_device_t *dev0,
                              sensors_event_t* data, int count)
{
    return -EIO;
}

static int sensor_device_activate(struct sensors_poll_device_t *dev0,
                                  int handle,
                                  int enabled)
{
    SensorDevice* dev = (void*)dev0;

    D("%s: handle=%s (%d) enabled=%d", __FUNCTION__,
        _sensorIdToName(handle), handle, enabled);

    /* Sanity check */
    if (!ID_CHECK(handle)) {
        E("%s: bad handle ID", __FUNCTION__);
        return -EINVAL;
    }

    /* Exit early if sensor is already enabled/disabled. */
    uint32_t mask = (1U << handle);
    uint32_t sensors = enabled ? mask : 0;

    pthread_mutex_lock(&dev->lock);

    uint32_t active = dev->active_sensors;
    uint32_t new_sensors = (active & ~mask) | (sensors & mask);
    uint32_t changed = active ^ new_sensors;

    if (changed)
	    dev->active_sensors = new_sensors;

    pthread_mutex_unlock(&dev->lock);
    return 0;
}

static int sensor_device_default_flush(
        struct sensors_poll_device_1* dev0,
        int handle) {

    SensorDevice* dev = (void*)dev0;

    D("%s: handle=%s (%d)", __FUNCTION__,
        _sensorIdToName(handle), handle);

    /* Sanity check */
    if (!ID_CHECK(handle)) {
        E("%s: bad handle ID", __FUNCTION__);
        return -EINVAL;
    }

    pthread_mutex_lock(&dev->lock);
    dev->sensors[handle].version = META_DATA_VERSION;
    dev->sensors[handle].type = SENSOR_TYPE_META_DATA;
    dev->sensors[handle].sensor = 0;
    dev->sensors[handle].timestamp = 0;
    dev->sensors[handle].meta_data.what = META_DATA_FLUSH_COMPLETE;
    dev->pendingSensors |= (1U << handle);
    pthread_mutex_unlock(&dev->lock);

    return 0;
}

static int sensor_device_set_delay(struct sensors_poll_device_t *dev0,
                                   int handle __unused,
                                   int64_t ns)
{
    return 0;
}

static int sensor_device_default_batch(
     struct sensors_poll_device_1* dev,
     int sensor_handle,
     int flags,
     int64_t sampling_period_ns,
     int64_t max_report_latency_ns) {
    return sensor_device_set_delay(dev, sensor_handle, sampling_period_ns);
}

/** MODULE REGISTRATION SUPPORT
 **
 ** This is required so that hardware/libhardware/hardware.c
 ** will dlopen() this library appropriately.
 **/

/*
 * the following is the list of all supported sensors.
 * this table is used to build sSensorList declared below
 * according to which hardware sensors are reported as
 * available from the emulator (see get_sensors_list below)
 *
 * note: numerical values for maxRange/resolution/power for
 *       all sensors but light, pressure and humidity were
 *       taken from the reference AK8976A implementation
 */
static const struct sensor_t sSensorListInit[] = {
        { .name       = "Accelerometer",
          .vendor     = "The Android Open Source Project",
          .version    = 1,
          .handle     = ID_ACCELERATION,
          .type       = SENSOR_TYPE_ACCELEROMETER,
          .maxRange   = 2.8f,
          .resolution = 1.0f/4032.0f,
          .power      = 3.0f,
          .minDelay   = 10000,
          .maxDelay   = 60 * 1000 * 1000,
          .fifoReservedEventCount = 0,
          .fifoMaxEventCount =   0,
          .stringType =         0,
          .requiredPermission = 0,
          .flags = SENSOR_FLAG_CONTINUOUS_MODE,
          .reserved   = {}
        },
};

static struct sensor_t  sSensorList[1];

static int sensors__get_sensors_list(struct sensors_module_t* module __unused,
        struct sensor_t const** list)
{
    *list = sSensorList;

    return 0;
}

static int
open_sensors(const struct hw_module_t* module,
             const char*               name,
             struct hw_device_t*      *device)
{
    int  status = -EINVAL;

    D("%s: name=%s", __FUNCTION__, name);

    if (!strcmp(name, SENSORS_HARDWARE_POLL)) {
        SensorDevice *dev = malloc(sizeof(*dev));

        memset(dev, 0, sizeof(*dev));

        dev->device.common.tag     = HARDWARE_DEVICE_TAG;
        dev->device.common.version = SENSORS_DEVICE_API_VERSION_1_3;
        dev->device.common.module  = (struct hw_module_t*) module;
        dev->device.common.close   = sensor_device_close;
        dev->device.poll           = sensor_device_poll;
        dev->device.activate       = sensor_device_activate;
        dev->device.setDelay       = sensor_device_set_delay;

        // Version 1.3-specific functions
        dev->device.batch       = sensor_device_default_batch;
        dev->device.flush       = sensor_device_default_flush;

        dev->fd = -1;
        pthread_mutex_init(&dev->lock, NULL);

        *device = &dev->device.common;
        status  = 0;
    }
    return status;
}


static struct hw_module_methods_t sensors_module_methods = {
    .open = open_sensors
};

struct sensors_module_t HAL_MODULE_INFO_SYM = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .version_major = 1,
        .version_minor = 0,
        .id = SENSORS_HARDWARE_MODULE_ID,
        .name = "Dummy SENSORS Module",
        .author = "The Android Open Source Project",
        .methods = &sensors_module_methods,
    },
    .get_sensors_list = sensors__get_sensors_list
};
