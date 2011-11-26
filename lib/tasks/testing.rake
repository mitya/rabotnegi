namespace :test do
  task :web do
    sh "rake test:web_internal X_RAILS_ENV=test_web"
  end

  Rake::TestTask.new(:web_internal) do |t|
    t.libs << "test"
    t.pattern = 'test/web/**/*_test.rb'
    t.verbose = true
    t.options = "--verbose=verbose"
  end
  
  task :web_seed do
    sh "rake data:seed[web] RAILS_ENV=test_web"
  end
  
  TestTaskWithoutDescription.new(:plumbing) do |t|
    t.libs << "test"
    t.pattern = 'test/plumbing/**/*_test.rb'
  end  
  
  TestTaskWithoutDescription.new(:all) do |t|
    t.libs << "test"
    t.test_files = FileList[
      'test/unit/**/*_test.rb',
      'test/plumbing/**/*_test.rb', 
      'test/functionals/**/*_test.rb',
      'test/integration/**/*_test.rb',
      'test/helpers/**/*_test.rb',
    ]
  end
end
