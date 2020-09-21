import std.stdio;
import std.typecons;
import std.algorithm;
import std.meta : AliasSeq;
import std.conv;
import std.exception;

import bindbc.sdl;

import erupted;
import core.sys.windows.windows;

void main() {
	import erupted.vulkan_lib_loader;
	import core.stdc.string : strcmp;
	import std.string : toStringz;

	import saun_instance = saun.internal_gfx.vulkan.instance;
	import saun.internal_gfx.vulkan.instance : InstanceFeature;
	
	import saun_device = saun.internal_gfx.vulkan.device;
	import saun.internal_gfx.vulkan.device : QueueType;

	import saun_window = saun.internal_gfx.vulkan.window;

	import saun.internal_gfx.vulkan.debug_info: vkDbg;

	loadSDL();
	loadGlobalLevelFunctions();

	SDL_Window *win = SDL_CreateWindow("Hello", SDL_WINDOWPOS_UNDEFINED,
		SDL_WINDOWPOS_UNDEFINED, 900, 600, SDL_WindowFlags.SDL_WINDOW_VULKAN);
	scope(exit) {
		SDL_Delay(1000);
		SDL_DestroyWindow(win);
		SDL_Quit();
	}


version(none) {
	const layers = saun_instance.getSupported(InstanceFeature.Layer);
	const exts = saun_instance.getSupported(InstanceFeature.Extension);

	writeln("Layers Supported:");
	layers.each!(layer => writeln("\t", layer));
	writeln("Extensions Supported:");
	exts.each!(ext => writeln("\t", ext));
}




	string[] exts = ["VK_EXT_debug_report", VK_EXT_DEBUG_UTILS_EXTENSION_NAME];
	string[] layers = ["VK_LAYER_KHRONOS_validation"];
	
	{
		import saun_conv = saun.util.conv;
		uint num = 0;
		const(char)*[] sdlExts;
		SDL_Vulkan_GetInstanceExtensions(win, &num, null);
		sdlExts.length = num;
		SDL_Vulkan_GetInstanceExtensions(win, &num, sdlExts.ptr);
		exts ~= saun_conv.to(sdlExts);
	}

	enforce(
		saun_instance.pollSupported(InstanceFeature.Extension, exts) &&
		saun_instance.pollSupported(InstanceFeature.Layer, layers),
		"Vulkan does not have Extensions or Layers needed to work!"
	);


	VkInstance instance;
	{
		auto createInfo = saun_instance.makeInstanceInfo(["VK_EXT_debug_report"], ["VK_LAYER_KHRONOS_validation"]);
		vkCreateInstance(&createInfo, null, &instance).vkDbg;
		loadInstanceLevelFunctions(instance);
	}
	VkPhysicalDevice gpu = saun_device.getSuitableDevice(instance, (features) => true);
	auto queueIndices = saun_device.getQueueIndices(
		gpu, [QueueType.Graphics]);
	
	VkDevice device; 
	{
		auto createInfo = saun_device.makeDeviceInfo(queueIndices);
		vkCreateDevice(gpu, &createInfo, null, &device).vkDbg;
		loadDeviceLevelFunctions(device);
	}

	SDL_SysWMinfo wInfo;
	SDL_VERSION(&wInfo.version_);
	SDL_GetWindowWMInfo(win, &wInfo);
    
	VkSurfaceKHR surface; 

	saun_window.WindowHandle winHandle = {
		ndt : wInfo.info.win.window,
		nwh : GetModuleHandle(null)
	};
	saun_window.createSurface(instance, &surface, winHandle);


	vkDestroyDevice(device, null);
	vkDestroyInstance(instance, null);
	
}
