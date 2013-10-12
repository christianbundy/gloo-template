FileList['./**/**/Rakefile'].each { |path|
    if path != './Rakefile'
        Dir.chdir(File.dirname(path)) do
            system $command
        end
    end
}