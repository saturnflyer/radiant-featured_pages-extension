namespace :radiant do
  namespace :extensions do
    namespace :featured_pages do
      
      desc "Runs the migration of the Featured Pages extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          FeaturedPagesExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          FeaturedPagesExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Featured Pages to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[FeaturedPagesExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(FeaturedPagesExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
