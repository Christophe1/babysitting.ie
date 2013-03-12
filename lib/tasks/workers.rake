require 'resque_scheduler/tasks'

namespace :workers do
  desc "Stops background workers"
  task :stop => :environment do
    pid = Rails.root.to_s + "/tmp/pids/resque.pid"
    hostname = `hostname`.gsub("\n", '')

    host_workers = Resque.workers.select{|w| w.to_s.split(":").first == hostname }
    pids = host_workers.map{|worker| worker.to_s.split(':')[1] }.reject{|p| p.to_i == Process.pid }

    puts "Killing #{pids.join(' ')}"
    `kill -s QUIT #{pids.join(' ')}` rescue nil

    if FileTest.exists?(pid)
      `rm -f #{pid}`
      puts 'PID removed'
    end
    puts 'Resque stopped'
  end

  desc "Starts background workers"
  task :start => :environment do
    config = YAML.load(File.read(Rails.root.to_s + "/config/resque.yml"))[Rails.env]
    pid = Rails.root.to_s + "/tmp/pids/resque.pid"
    if FileTest.exists?(pid)
      puts "Can't start workers: PID #{pid} already exists."
    else
      log = Rails.root.to_s + "/log/resque_worker.log"
      cmd = "RAILS_ENV=#{Rails.env} QUEUES=#{config['queue'].join(',')} COUNT=#{config['workers']} nohup bundle exec rake resque:workers"
      puts cmd
      `sh -c '#{ cmd } > #{ log } & echo $! > #{pid}'`
    end
  end
end

namespace :scheduler do
  desc "Restart scheduler"
  task :restart => :environment do
    Rake::Task['scheduler:stop'].invoke
    Rake::Task['scheduler:start'].invoke
  end

  desc "Quit scheduler"
  task :stop => :environment do
    pidfile = "#{Rails.root}/tmp/pids/resque_scheduler.pid"
    if File.exists?(pidfile)
      pid = File.read(pidfile).to_i
      `kill -9 #{pid}`
      FileUtils.rm_f(pidfile)
    else
      puts "Scheduler not running"
    end
  end

  desc "Start scheduler"
  task :start => :environment do
    pidfile = "#{Rails.root}/tmp/pids/resque_scheduler.pid"
    cmd = "PIDFILE=#{pidfile} VERBOSE=true BACKGROUND=true bundle exec rake resque:scheduler"
    puts cmd
    `sh -c '#{cmd}'`
  end
end