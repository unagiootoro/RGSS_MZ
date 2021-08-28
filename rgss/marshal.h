#ifndef MRUBY_MARSHAL_H
#define MRUBY_MARSHAL_H

#if defined(__cplusplus)
extern "C" {
#endif

extern void mrb_mruby_marshal_gem_init(mrb_state* M);

mrb_value mrb_marshal_dump(mrb_state* M, mrb_value v, mrb_value out);
mrb_value mrb_marshal_load(mrb_state* M, mrb_value str);

#if defined(__cplusplus)
}  /* extern "C" { */
#endif

#endif  /* MRUBY_ARRAY_H */
