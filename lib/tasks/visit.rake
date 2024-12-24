require 'browser'

namespace :visit do
  desc 'Visit User Agent'
  task ua: :environment do
    Visit.all.each do |v|
      b = Browser.new(v.user_agent)
      puts("ID: #{v.id}\tBot: #{b.bot?}\tBrowser: #{b.name}\t\tPlatform: #{b.platform.name}\tPlatform Version: #{b.platform.version}")
      puts("\t\t\tMobile: #{b.device.mobile?}\tTablet: #{b.device.tablet?}")
    end
  end
end
