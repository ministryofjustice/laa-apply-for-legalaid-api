namespace :mp do
  desc 'Turn on muliple proceedings and populate section 8 proceeding types'
  task pop: :environment do
    Setting.setting.update!(allow_multiple_proceedings: true)
    Rake::Task['db:seed'].invoke
  end
end
