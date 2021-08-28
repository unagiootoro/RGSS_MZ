class CodeGenerator
  def initialize
    @interface_list = []
  end

  def interface(name, args, ret)
    @interface_list.push({ name: name, args: args, ret: ret })
  end

  def run
    c_src = generate_c_src
    js_src = generate_js_src
    File.write("rgss_c_interface.c", c_src)
    File.write("rgss_js_interface.js", js_src)
  end

  def generate_c_src
    CGenerator.new.generate(@interface_list)
  end

  def generate_js_src
    JSGenerator.new.generate(@interface_list)
  end
end

class CGenerator
  def generate(interface_list)
    src = ""
    interface_list.each do |interface|
      src << gen_interface(interface) << "\n"
    end
    ""
  end

  def gen_interface(interface)
    <<-EOS
static mrb_value mrb_interface_#{interface.name}(mrb_state *mrb, mrb_value self) {
  mrb_value mrb_file_name, mrb_buf;
  mrb_get_args(mrb, "oo", &mrb_file_name, &mrb_buf);
  const char* file_name = mrb_str_to_cstr(mrb, mrb_file_name);
  int buf_size = 0;
  char* buf = RSTRING_PTR(mrb_buf);
  interface_#{interface.name}();
  return mrb_fixnum_value(buf_size);
}
    EOS
  end
end

class JSGenerator
  def generate(interface_list)
    ""
  end
end

gen = CodeGenerator.new
gen.interface("Sprite_new", { sprite_id: "i32", viewport_id: "i32" }, "i32")
gen.run
