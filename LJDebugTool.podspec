Pod::Spec.new do |s|
    s.name         = "LJDebugTool"
    s.version      = "1.0.3"
    s.ios.deployment_target = '10.0'
    s.summary      = "日志实时显示、收集、导出"
    s.homepage     = "https://github.com/bikeboy7/LJDebugTool"
    s.license              = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "bikeBoy7" => "810256984@qq.com" }
    s.source_files  = "LJDebugTool", "LJDebugTool/**/*.{swift}"
    s.source       = { :git => "https://github.com/bikeboy7/LJDebugTool.git", :tag => s.version }
    s.swift_version = '5.0'
end

