module Crypto42
  class Button
    def initialize(data)
      my_cert_file = Dir.getwd + "/paypal/my-pubcert.pem"
      my_key_file = Dir.getwd + "/paypal/my-prvkey.pem"
      paypal_cert_file = Dir.getwd + "/paypal/paypal_cert.pem"

      IO.popen("/Sites/coffee_store/usr/bin/GNU/bin/openssl smime -sign -signer #{my_cert_file} -inkey #{my_key_file} -outform der -nodetach -binary | /Sites/coffee_store/usr/bin/GNU/bin/openssl smime -encrypt -des3 -binary -outform pem #{paypal_cert_file}", 'r+') do |pipe|
        data.each { |x,y| pipe << "#{x}=#{y}\n" }
        pipe.close_write
        @data = pipe.read
      end
    end

    def self.from_hash(hs)
      self.new hs
    end

    def get_encrypted_text
      return @data
    end

  end #end button
end #end module

