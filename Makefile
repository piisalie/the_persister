default:
	ruby -e "Dir.glob('./test/*_test.rb').each { |file| require file}"
