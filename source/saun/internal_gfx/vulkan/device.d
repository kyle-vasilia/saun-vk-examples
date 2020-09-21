module saun.internal_gfx.vulkan.device;
import std.algorithm;

import erupted; 


enum QueueType {
    Graphics = VK_QUEUE_GRAPHICS_BIT
}

uint[QueueType] getQueueIndices(VkPhysicalDevice gpu, QueueType[] queuesNeeded) {
    uint[QueueType] indices;
    
    uint num = 0;
    VkQueueFamilyProperties[] queues;

    vkGetPhysicalDeviceQueueFamilyProperties(gpu, &num, null);
    queues.length = num;
    vkGetPhysicalDeviceQueueFamilyProperties(gpu, &num, queues.ptr);

    queues.each!((i, n) {
        foreach(type; queuesNeeded) {
            if(n.queueFlags & type) 
                indices[type] = cast(uint)i;
        }
    });
    return indices;
}


VkPhysicalDevice getSuitableDevice(VkInstance instance, bool delegate(VkPhysicalDeviceFeatures) fn) {
    VkPhysicalDevice[] devices;
    uint deviceNum = 0;
    vkEnumeratePhysicalDevices(instance, &deviceNum, null);
    devices.length = deviceNum;
    vkEnumeratePhysicalDevices(instance, &deviceNum, devices.ptr);    

    VkPhysicalDevice chosenDevice = VK_NULL_HANDLE;
    devices.each!((gpu) {
		VkPhysicalDeviceFeatures features;
		vkGetPhysicalDeviceFeatures(gpu, &features);
        if(fn(features)) {
            chosenDevice = gpu;
        }

	});

    return chosenDevice;
}

VkDeviceCreateInfo makeDeviceInfo(uint[QueueType] indices) {
    VkDeviceQueueCreateInfo[] queueInfos;
    float* priority = new float(1.0f);

    foreach(index, type; indices) {
        VkDeviceQueueCreateInfo queue = {
            queueFamilyIndex : index,
            queueCount : 1,
            pQueuePriorities : priority
        };
        queueInfos ~= queue;
    }
    auto features = new VkPhysicalDeviceFeatures;
    VkDeviceCreateInfo createInfo = {
        pQueueCreateInfos : queueInfos.ptr,
		queueCreateInfoCount : cast(uint)queueInfos.length,
		pEnabledFeatures : features
    };
    return createInfo;
}