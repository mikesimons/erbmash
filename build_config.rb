MRuby::Build.new do |conf|
  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  conf.gembox 'full-core'
  conf.gem :git => 'https://github.com/jbreeden/mruby-erb.git'
  conf.gem :git => 'https://github.com/iij/mruby-regexp-pcre.git'
  conf.gem :git => 'https://github.com/iij/mruby-env.git'
  conf.gem :git => 'https://github.com/AndrewBelt/mruby-yaml.git'
end