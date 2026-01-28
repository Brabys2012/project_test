def logger_initialize
  $logger = Logger.new(STDOUT)
  $logger.formatter = proc do |severity, datetime, _progname, msg|
    color = case severity
            when 'UNKNOWN'
              :gray
            when 'FATAL'
              :bg_red
            when 'ERROR'
              :red
            when 'WARN'
              :brown
            when 'INFO'
              :blue
            when 'DEBUG'
              :bg_gray
            else
              raise "Unknown severity #{severity}"
            end
    "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{severity} -- #{msg}\n".send(color)
  end
end
