module saun.internal_gfx.vulkan.debug_info;
import core.stdc.stdio;
import erupted;
import std.exception;
import std.conv;

extern(Windows) VkBool32 dbgCallback(
	VkDebugUtilsMessageSeverityFlagBitsEXT messageSevere,
	VkDebugUtilsMessageTypeFlagsEXT type,
	const (VkDebugUtilsMessengerCallbackDataEXT) *callbackData,
	void *userData
) nothrow @nogc {
	printf("ERR ERR ERR: ");
	printf(callbackData.pMessage);
	printf("\n");
	return VK_FALSE;
}


void vkDbg(VkResult res) {
    enforce(res == VK_SUCCESS, res.to!string);
}

