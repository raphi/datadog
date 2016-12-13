require 'date'
require 'uri'

# Ruby representation of the Common Log model as defined here:
# https://www.w3.org/Daemon/User/Config/Logging.html#common-logfile-format
#
class CommonLog
  attr_reader :ip, :user_identifier, :user_id, :date, :http_status,
              :http_verb, :http_version, :status, :section, :uri, :bytes

  def initialize(*args)
    # Replace the NCSA Common Log Format missing data indicator "-" to a Ruby `nil`
    ip, user_identifier, user_id, date, request, status, bytes = args.map! { |arg| arg == '-' ? nil : arg }

    @ip = ip
    @user_identifier = user_identifier
    @user_id = user_id
    @date = DateTime.strptime(date, format = '%e/%b/%Y:%H:%M:%S %z') if date
    @http_verb, uri, @http_version = request.split if request
    @uri = URI(uri) if uri
    # A section is defined as being what's before the second '/' in a URL.
    # i.e. the section for "http://my.site.com/pages/create' is "http://my.site.com/pages")
    @section = @uri.path.split('/')[0...-1].join('/') if uri
    @status = status.to_i if status
    @bytes = bytes.to_i if bytes
  end

  # Valid Common Log format according to specifications
  #
  def valid?
    # Written like that for efficiency
    !(@ip.nil? || @date.nil? || @http_verb.nil? || @uri.nil? || @http_version.nil? || @status.nil? || @bytes.nil?)
  end

  def to_s
    uid = user_id.nil? ? '-' : user_id
    uuid = user_identifier.nil? ? '-' : user_identifier

    "%s %s %s [%s] \"%s %s %s\" %s %s" % [ip, uid, uuid, date, http_verb, uri.to_s, http_version, status, bytes]
  end
end
