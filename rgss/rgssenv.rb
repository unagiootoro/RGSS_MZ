if RUBY_ENGINE == "opal"
  module RGSSEnv_Message
    def send_message(type, hash)
      if hash
        obj = `{}`
        hash.each do |key, val|
          if val
            `obj[key] = val`
          else
            `obj[key] = null`
          end
        end
      else
        obj = `null`
      end
      result = nil
      %x{
        const sharedBuffer = new SharedArrayBuffer(8);
        const bufferView = new Int32Array(sharedBuffer);
        global.postMessage([#{type}, sharedBuffer, #{obj}]);
        let loopCount = 0;
        while (true) {
          loopCount++;
          if (loopCount > 100000000) {
            global.postMessage(["debug_log", null, #{type} + " is no responced."]);
            while (true) {}
          }
          if (bufferView[0] === 1) {
            break;
          }
        }
        result = bufferView[1];
      }
      result
    end

    def debug_log(log)
      %x{
        global.postMessage(["debug_log", null, #{log}]);
      }
    end

    def file_read(file_path)
      file_data_array = nil
      %x{
        const sharedBuffer = new SharedArrayBuffer(8);
        const bufferView = new Int32Array(sharedBuffer);
        global.postMessage(["file_read_start", sharedBuffer, file_path]);
        while (true) {
          if (bufferView[0] === 1) {
            break;
          }
        }
        const dataSize = bufferView[1];
        const sharedBuffer2 = new SharedArrayBuffer(dataSize * 4);
        const bufferView2 = new Uint32Array(sharedBuffer2);
        bufferView[0] = 0;
        global.postMessage(["file_read", sharedBuffer, sharedBuffer2]);
        while (true) {
          if (bufferView[0] === 1) {
            break;
          }
        }
        #{
          file_data_array = Array.new(`dataSize`)
          `dataSize`.times do |i|
            file_data_array[i] = `String.fromCodePoint(bufferView2[i])`
          end
        }
      }
      file_data = file_data_array.join("")
      file_data
    end
  end
elsif RUBY_ENGINE == "mruby"
  module RGSSEnv_Message
    def send_message(type, hash)
      if RGSS_MODE == :client
        # send_data = JSON.stringify({ type: type, obj: hash })

        if hash
          base_array = []
          hash.each.with_index do |(key, val), i|
            if val.is_a?(String)
              strval = %`"#{val}"`
            elsif val == nil
              strval = "null"
            else
              strval = val.to_s
            end
            base_array << %`"#{key}": #{strval}`
          end
          obj_data = "{#{base_array.join(',')}}"
        else
          obj_data = "null"
        end
        send_data = %`{"type": "#{type}","obj": #{obj_data}}`

        res = rgss_send_message(send_data)
        res
      else
        uri = "http://localhost:7000/"
        http = HttpRequest.new
        hash = hash.to_h do |key, val|
          # rescue_flg = false
          # begin
          #   if val.is_a?(String)
          #     val = val.encode("UTF-8")
          #   end
          # rescue
          #   rescue_flg = true
          # end
  
          # if rescue_flg
          #   begin
          #     val.force_encoding("UTF-8")
          #     val = val.split("").join("")
          #   rescue
          #     val = ""
          #   end
          # end
  
          [key, val]
        end
  
        begin
          send_data = JSON.dump({ type: type, obj: hash })
        rescue
          hash = hash.to_h do |key, val|
            if val.is_a?(String)
              val = ""
            end
            [key, val]
          end
          send_data = JSON.dump({ type: type, obj: hash })
        end
  
        res = http.post(uri, send_data, { "Content-Type" => "application/json" })
        res.body.to_i
      end
    end

    def debug_log(log)
    end

    def file_read(file_path)
      if RGSS_MODE == :client
        buf = "\0" * 600000
        buf_len = rgss_file_read(file_path, buf)
        buf[0...buf_len]
      else
        res = File.read("../" + file_path)
        res
      end
    end
  end
else
  module RGSSEnv_Message
    def send_message(type, hash)
      uri = URI.parse("http://localhost:8000/")
      http = Net::HTTP.new(uri.host, uri.port)
      hash = hash.to_h do |key, val|
        rescue_flg = false
        begin
          if val.is_a?(String)
            val = val.encode("UTF-8")
          end
        rescue
          rescue_flg = true
        end

        if rescue_flg
          begin
            val.force_encoding("UTF-8")
            val = val.split("").join("")
          rescue
            val = ""
          end
        end

        [key, val]
      end

      begin
        send_data = JSON.dump({ type: type, obj: hash })
      rescue
        hash = hash.to_h do |key, val|
          if val.is_a?(String)
            val = ""
          end
          [key, val]
        end
        send_data = JSON.dump({ type: type, obj: hash })
      end

      res = http.post(uri.path, send_data, { "Content-Type" => "application/json" })
      res.body.to_i
    end

    def debug_log(log)
    end

    def file_read(file_path)
      res = File.read("../" + file_path)
      res
    end
  end
end

module RGSSEnv
  extend RGSSEnv_Message

  class << self

    def check_graphics_updated
      updated = send_message("Graphics_check_updated", nil)
      return true if updated == 1
      return false
    end

    # def input_is_pressed(keyname)
    #   hash = { keyname: keyname }
    #   res = send_message("Input_is_pressed", hash)
    #   return true if res == 1
    #   return false
    # end

    # def input_is_triggered(keyname)
    #   hash = { keyname: keyname }
    #   res = send_message("Input_is_triggered", hash)
    #   return true if res == 1
    #   return false
    # end

    # def input_is_repeated(keyname)
    #   hash = { keyname: keyname }
    #   res = send_message("Input_is_repeated", hash)
    #   return true if res == 1
    #   return false
    # end

    # def input_dir4
    #   send_message("Input_dir4", nil)
    # end

    # def input_dir8
    #   send_message("Input_dir8", nil)
    # end

  end
end
