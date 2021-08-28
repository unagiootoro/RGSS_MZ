=begin
Input
ゲームパッドやキーボードからの入力情報を扱うモジュール。

モジュールメソッドInput.update 
入力情報を更新します。原則として 1 フレームに 1 回呼び出します。

Input.press?(num) 
番号 num に対応するボタンが、現在押されているかどうかを判定します。

押されていれば true、押されていなければ false を返します。

if Input.press?(Input::C)
  do_something
end

Input.trigger?(num) 
番号 num に対応するボタンが、新たに押されたかどうかを判定します。

押されていない状態から押された状態に変わった瞬間のみ「新たに押された」とみなされます。

押されていれば true、押されていなければ false を返します。

Input.repeat?(num) 
番号 num に対応するボタンが、新たに押されたかどうかを判定します。

trigger? と異なり、ボタンを押し続けた場合のリピートを考慮します。

押されていれば true、押されていなければ false を返します。

Input.dir4 
方向ボタンの状態を判定し、4 方向入力に特化した形で、テンキーの数字に対応する整数 (2, 4, 6, 8) を返します。

方向ボタンが押されていない場合 (またはそれと同等とみなされる場合) は 0 を返します。

Input.dir8 
方向ボタンの状態を判定し、8 方向入力に特化した形で、テンキーの数字に対応する整数 (1, 2, 3, 4, 6, 7, 8, 9) を返します。

方向ボタンが押されていない場合 (またはそれと同等とみなされる場合) は 0 を返します。

定数DOWN LEFT RIGHT UP 
方向ボタンの下、左、右、上に対応する番号です。

A B C X Y Z L R 
各々のボタンに対応する番号です。

SHIFT CTRL ALT 
キーボードの SHIFT、CTRL、ALT キーに直接対応する番号です。

F5 F6 F7 F8 F9 
キーボードの各ファンクションキーに対応する番号です。これ以外のキーはシステムに予約されているため、取得することはできません。

=end

module Input
  @@key_table = {
    9 => "tab",
    13 => "ok",
    16 => "shift",
    17 => "control",
    18 => "control",
    27 => "escape",
    32 => "ok",
    33 => "pageup",
    34 => "pagedown",
    37 => "left",
    38 => "up",
    39 => "right",
    40 => "down",
    45 => "escape",
    81 => "pageup",
    87 => "pagedown",
    88 => "escape",
    90 => "ok",
    96 => "escape",
    98 => "down",
    100 => "left",
    102 => "right",
    104 => "up",
    120 => "debug"
  }

  class << self
    def _init
      @@key_state = {}
      @@key_table.each_key do |num|
        @@key_state[num] = 0
      end
    end

    def _get_keycode(target_keyname)
      @@key_table.each do |keycode, keyname|
        return keycode if keyname == target_keyname
      end
      raise "keycode not found: #{target_keyname}"
    end

    def update
      @@key_table.each_key do |num|
        if RGSSEnv.input_is_pressed(num) == 1
          if @@key_state[num] == 0
            @@key_state[num] = 1
          elsif @@key_state[num] == 1
            @@key_state[num] = 2
          end
        else
          @@key_state[num] = 0
        end
      end
    end

    def press?(num)
      # RGSSEnv.input_is_pressed(num) == 1
      @@key_state[num] >= 1
    end

    def trigger?(num)
      # RGSSEnv.input_is_triggered(num) == 1
      @@key_state[num] == 1
    end

    def repeat?(num)
      RGSSEnv.input_is_repeated(num) == 1
    end

    def dir4
      RGSSEnv.input_dir4
    end

    def dir8
      RGSSEnv.input_dir8
    end
  end
end

Input._init
Input::B = Input._get_keycode("escape")
Input::C = Input._get_keycode("ok")
Input::UP = Input._get_keycode("up")
Input::DOWN = Input._get_keycode("down")
Input::LEFT = Input._get_keycode("left")
Input::RIGHT = Input._get_keycode("right")
Input::L = Input._get_keycode("pageup")
Input::R = Input._get_keycode("pagedown")
