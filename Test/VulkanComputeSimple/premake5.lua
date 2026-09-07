project "VulkanComputeSimple"
    kind "ConsoleApp"

    location "%{wks.location}/Test/%{prj.name}"

    useOrochi()
    linkWin32SystemLibs()
    externalincludedirs { "./" }
    files { "*.cpp" }
