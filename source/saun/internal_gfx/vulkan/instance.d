module saun.internal_gfx.vulkan.instance;
import std.algorithm;
import std.conv;
import std.range;
import std.string;
import erupted; 

import saun_conv = saun.util.conv;

enum InstanceFeature {
    Extension,
    Layer
}

/*
Note:
    A lot of these functions are very slow with usage of actual long arrays,
    this is fine, they're only used once. 

    makeCreateInfo heap allocates, keep the createInfo return in a scope where it's destroyed
    so memory can be deallocated. 

*/
bool pollSupported(InstanceFeature type, string[] features) {
    uint num = 0;
    string[] available;

    switch(type) {
    case InstanceFeature.Extension:
        VkExtensionProperties[] exts;
        vkEnumerateInstanceExtensionProperties(null, &num, null);
        exts.length = num;
        vkEnumerateInstanceExtensionProperties(null, &num, exts.ptr);
        foreach(ext; exts) {
            available ~= to!string(ext.extensionName).replace('\0', ' ').strip;
        }
        break;
    case InstanceFeature.Layer:
        VkLayerProperties[] layers; 
        vkEnumerateInstanceLayerProperties(&num, null);
        layers.length = num;
        vkEnumerateInstanceLayerProperties(&num, layers.ptr);
        foreach(layer; layers) {
            available ~= to!string(layer.layerName).replace('\0', ' ').strip;
        }
        break;
    default: assert(0);
    } 

    foreach(feature; features) {
        if(available.find(feature).empty) return false;
    }

    return true;
}

string[] getSupported(InstanceFeature type) {
    uint num = 0;
    string[] available;
    switch(type) {
    case InstanceFeature.Extension:
        VkExtensionProperties[] exts;
        vkEnumerateInstanceExtensionProperties(null, &num, null);
        exts.length = num;
        vkEnumerateInstanceExtensionProperties(null, &num, exts.ptr);
        foreach(ext; exts) {
            available ~= to!string(ext.extensionName).replace('\0', ' ').strip;
        }
        break;
    case InstanceFeature.Layer:
        VkLayerProperties[] layers; 
        vkEnumerateInstanceLayerProperties(&num, null);
        layers.length = num;
        vkEnumerateInstanceLayerProperties(&num, layers.ptr);
        foreach(layer; layers) {
            available ~= to!string(layer.layerName).replace('\0', ' ').strip;
        }
        break;
    default: assert(0);
    } 

    return available;
}

VkInstanceCreateInfo makeInstanceInfo(string[] exts, string[] layers) {
    import saun.internal_gfx.vulkan.debug_info : dbgCallback;
    auto appInfo = new VkApplicationInfo;
    appInfo.pApplicationName = "saun-engine runtime";
    appInfo.apiVersion = VK_API_VERSION_1_1;

	auto debugInfo = new VkDebugUtilsMessengerCreateInfoEXT();
	debugInfo.messageSeverity = 
				VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | 
				VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | 
				VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
	debugInfo.messageType = 
				VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | 
				VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | 
				VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT; 
	debugInfo.pfnUserCallback = &dbgCallback;


    VkInstanceCreateInfo createInfo = {
        pApplicationInfo : appInfo,
        pNext : debugInfo,

        enabledExtensionCount : cast(uint)exts.length,
        ppEnabledExtensionNames : saun_conv.to(exts).ptr,

        enabledLayerCount : cast(uint)layers.length,
        ppEnabledLayerNames : saun_conv.to(layers).ptr
    };
    return createInfo;
}
