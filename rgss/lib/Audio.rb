=begin
Audio
ミュージック、サウンドにかかわる処理を行うモジュール。

モジュールメソッドAudio.bgm_play(filename[, volume[, pitch]]) 
BGM の演奏を開始します。順にファイル名、ボリューム、ピッチを指定します。

RGSS-RTP に含まれるファイルも自動的に探します。拡張子は省略可能です。

Audio.bgm_stop 
BGM の演奏を停止します。

Audio.bgm_fade(time) 
BGM のフェードアウトを開始します。time は、フェードアウトにかける時間をミリ秒単位で指定します。

Audio.bgs_play(filename[, volume[, pitch]]) 
BGS の演奏を開始します。順にファイル名、ボリューム、ピッチを指定します。

RGSS-RTP に含まれるファイルも自動的に探します。拡張子は省略可能です。

Audio.bgs_stop 
BGS の演奏を停止します。

Audio.bgs_fade(time) 
BGS のフェードアウトを開始します。time は、フェードアウトにかける時間をミリ秒単位で指定します。

Audio.me_play(filename[, volume[, pitch]]) 
ME の演奏を開始します。順にファイル名、ボリューム、ピッチを指定します。

RGSS-RTP に含まれるファイルも自動的に探します。拡張子は省略可能です。

Audio.me_stop 
ME の演奏を停止します。

Audio.me_fade(time) 
ME のフェードアウトを開始します。time は、フェードアウトにかける時間をミリ秒単位で指定します。

Audio.se_play(filename[, volume[, pitch]]) 
SE の演奏を開始します。順にファイル名、ボリューム、ピッチを指定します。

RGSS-RTP に含まれるファイルも自動的に探します。拡張子は省略可能です。

きわめて短期間に同じ SE を演奏しようとした場合、音割れを防止するため、自動的に間引き処理を行います。

Audio.se_stop 
すべての SE の演奏を停止します。
=end

module Audio
  class << self
    def bgm_play(filename, volume = 90, pitch = 100)
      return if filename == @playing_filename
      @playing_filename = filename
      file_path = _find_full_filename(filename)
      RGSSEnv.audio_midi_bgm_play(file_path, volume, pitch)
    end

    def bgm_stop
      RGSSEnv.audio_midi_bgm_stop
    end
    
    def bgm_fade(time)
      RGSSEnv.audio_midi_bgm_fade_out(time)
    end

    def bgs_play(filename, volume = 90, pitch = 100)
      RGSSEnv.audio_ogg_bgs_play(filename, volume, pitch)
    end

    def bgs_stop
      RGSSEnv.audio_ogg_bgs_stop
    end

    def bgs_fade(time)
      RGSSEnv.audio_ogg_bgs_fade_out(time)
    end

    def me_play(filename, volume = 90, pitch = 100)
      return if filename == @playing_filename
      @playing_filename = filename
      file_path = _find_full_filename(filename)
      RGSSEnv.audio_midi_me_play(file_path, volume, pitch)
    end

    def me_stop
      RGSSEnv.audio_midi_me_stop
    end

    def me_fade(time)
      RGSSEnv.audio_midi_me_fade_out(time)
    end

    def se_play(filename, volume, pitch)
      RGSSEnv.audio_ogg_se_play(filename, volume, pitch)
    end

    def se_stop
      RGSSEnv.audio_ogg_se_stop
    end

    def _find_full_filename(filename)
      match_data = filename.match(/(.+)\/(.+)$/)
      target_dname = match_data[1]
      target_fname = match_data[2]
      file_path = GRAPHICS_FILE_LIST.find do |path|
        match_data = path.match(/(.+)\/(.+)\..+$/)
        dname = match_data[1]
        fname = match_data[2]
        fname_no_ext = fname.gsub(/\..+/, "")
        if match_data
          if fname_no_ext.upcase == target_fname.upcase && dname.upcase == target_dname.upcase
            next true
          end
        end
        false
      end
      raise "#{filename} is not found." unless file_path
      file_path
    end
  end
end
