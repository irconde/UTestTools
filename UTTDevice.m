/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTTDevice.h"
#import "UTestTools.h"
#import "UTTConvertType.h"
#import "UTTUtils.h"
#import "UIDevice+Hardware.h"
#import "mach/mach.h" 

@implementation UTTDevice

static const NSString *UTT_PROPERTY_VALUE = @"value";
static const NSString *UTT_PROPERTY_OS = @"os";
static const NSString *UTT_PROPERTY_VERSION = @"version";
static const NSString *UTT_PROPERTY_NAME = @"name";
static const NSString *UTT_PROPERTY_RESOLUTION = @"resolution";
static const NSString *UTT_PROPERTY_BATTERY = @"battery";
static const NSString *UTT_PROPERTY_MEMORY = @"memory";
static const NSString *UTT_PROPERTY_CPU = @"cpu";
static const NSString *UTT_PROPERTY_DISK_SPACE = @"diskspace";
static const NSString *UTT_PROPERTY_ALL_INFO = @"allinfo";
static const NSString *UTT_PROPERTY_ORIENTATION = @"orientation";
static const NSString *UTT_PROPERTY_DISK_TOTAL = @"totalDiskSpace";
static const NSString *UTT_PROPERTY_RAM_TOTAL = @"totalMemory";
static const NSString *UTT_VALUE_PORTRAIT = @"portrait";
static const NSString *UTT_VALUE_LANDSCAPE = @"landscape";

+ (NSString *) os {
    return @"iOS";
}

//http://stackoverflow.com/questions/8223348/ios-get-cpu-usage-from-application
+ (NSString *)  getCPUUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    basic_info = (task_basic_info_t)tinfo;
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    float tot_cpu = 0;
    int j;
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        basic_info_th = (thread_basic_info_t)thinfo;
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    }
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return [NSString stringWithFormat:@"%d%%", (int)(tot_cpu)];
}

+ (NSString *) getRamPercentUsed {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        return @"Failed to fetch vm statistics";
    
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count);
    natural_t mem_free = vm_stat.free_count;
    return [NSString stringWithFormat:@"%u%%", ((100*mem_used)/(mem_used+mem_free))];
}

+ (NSString *)getDiskFullPercent {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    } else {
    }
    return [NSString stringWithFormat:@"%d%%", (int)(100-(100*totalFreeSpace)/totalSpace)];
}

+ (NSString *) getOSVersion{
    
    UIDevice *device = [UIDevice currentDevice];
    NSString * value = [device systemVersion];
//    NSMutableArray *argsArray = [[NSMutableArray alloc] initWithObjects:value, nil];
    
    return value;
}

+ (NSString *) getDeviceModel{
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *value = [device platform];
    

    
//    NSMutableArray *argsArray = [[NSMutableArray alloc] initWithObjects:value, nil];
    
    // Dispositivo Hardware
    
//    value = [device platformString];
      
    //Resolución del dispositivo
    
//    float width = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
//    float height = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;
//    value = [NSString stringWithFormat:@"%0.0fx%0.0f",width,height];
//    [argsArray addObject:value];
    
    
    return value;
}

+ (NSString *) getUDID {
    
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFUUIDCreateString(NULL,uuidRef);
    CFRelease(uuidRef);

    return uuidString;
}


+ (NSString *) foundValue:(NSArray *)args {
    UIDevice *device = [UIDevice currentDevice];
    NSString *value = [[self class] os];
    
    if ([args count] > 1) {
        if ([[args objectAtIndex:1] rangeOfString:@"."].location == 0) {
            value = [device valueForKeyPath:[[args objectAtIndex:1] substringFromIndex:1]];
        } else if ([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_OS] ||
                   [[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_VALUE]) {
            value = [[self class] os];
        } else if ([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_VERSION]) {
            value = [device systemVersion];
        } else if ([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_NAME]) {
            value = [device platformString];
        } else if ([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_RESOLUTION]) {
            
            float width = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
            float height = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;
            value = [NSString stringWithFormat:@"%0.0fx%0.0f",width,height];
        } else if ([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_ORIENTATION]) {
            
            NSInteger orientation;
            
            if ([[UTTUtils rootWindow] respondsToSelector:@selector(rootViewController)] && 
                [UTTUtils rootWindow].rootViewController)
                
                orientation = [[UTTUtils rootWindow].rootViewController interfaceOrientation];
            else {
                
                orientation = [UIApplication sharedApplication].statusBarOrientation;
            }
            
            if (orientation == UIInterfaceOrientationPortrait || 
                orientation == UIInterfaceOrientationPortraitUpsideDown)
                value = UTT_VALUE_PORTRAIT;
            else
                value = UTT_VALUE_LANDSCAPE;
        } else if([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_BATTERY]){
            
            BOOL monitoring = [device isBatteryMonitoringEnabled];
            [device setBatteryMonitoringEnabled:YES];
            value =  [NSString stringWithFormat:@"%d%%", (int)([device batteryLevel]*100)];
            
            [device setBatteryMonitoringEnabled:monitoring];
        } else if([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_MEMORY]){
            value = [[self class]getRamPercentUsed];
        } else if([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_CPU]){
            value = [[self class]getCPUUsage];
        } else if([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_DISK_SPACE]){
            value = [[self class] getDiskFullPercent];
        } else if([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_ALL_INFO]){
            BOOL monitoring = [device isBatteryMonitoringEnabled];
            [device setBatteryMonitoringEnabled:YES];
            NSString * battery = [NSString stringWithFormat:@"%d%%", (int)([device batteryLevel]*100)];
            [device setBatteryMonitoringEnabled:monitoring];
            value = [NSString stringWithFormat:@"%@,%@,%@,%@", [[self class]getRamPercentUsed], [[self class]getCPUUsage], [[self class] getDiskFullPercent], battery];
        } else if([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_DISK_TOTAL]){
            value = [NSString stringWithFormat:@"%@ bytes", ([device totalDiskSpace])];
        } else if([[args objectAtIndex:1] isEqualToString:UTT_PROPERTY_RAM_TOTAL]){
            value = [NSString stringWithFormat:@"%d bytes",[device totalMemory]];
        }
    }
    return value;
}

@end
