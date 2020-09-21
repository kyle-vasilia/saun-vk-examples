module saun.internal_gfx.vulkan.window;

import erupted;

import saun.internal_gfx.vulkan.platform.vulkan_windows;


struct WindowHandle {
    void *ndt;
    void *nwh;
}

void createSurface(VkInstance instance, VkSurfaceKHR* surface, const(WindowHandle) handle) {
    
version(Windows) {

    const(VkWin32SurfaceCreateInfoKHR) winHandle = {
		hwnd : handle.nwh,
		hinstance : handle.ndt
	};
    vkCreateWin32SurfaceKHR(instance, &winHandle, null, surface);
} else {
    static assert(0, "Your platform doesn't support saun-engine -Yet ;)-");
}

}