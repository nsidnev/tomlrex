use rustler::{Encoder, Env, Error, Term};
use toml::Value;
use toml::Value::{Array, Boolean, Datetime, Float, Integer, String as TomlString, Table};

mod atoms {
    use rustler::rustler_atoms;

    rustler_atoms! {
        atom ok;

        // This is for compatablity with toml-elixir
        atom invalid_toml;

        atom infinity;
        atom negative_infinity;

        atom nan;
        atom negative_nan;

        // This is need to convert date on Elixir side
        atom datetime;
    }
}

rustler::rustler_export_nifs! {
    "Elixir.Tomlrex.Native",
    [
        ("decode", 1, decode)
    ],
    None
}

fn decode<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let toml: String = args[0].decode()?;

    Ok(match toml.parse::<Value>() {
        Ok(v) => Ok(convert_value(&v, env)?),
        Err(e) => Err((atoms::invalid_toml(), e.to_string())),
    }.encode(env))
}

fn convert_value<'a>(v: &Value, env: Env<'a>) -> Result<Term<'a>, Error> {
    match v {
        Table(t) => {
            let mut map = Term::map_new(env);
            for (key, value) in t.iter() {
                map = map.map_put(key.encode(env), convert_value(value, env)?)?;
            }
            Ok(map)
        },
        TomlString(s) => Ok(s.encode(env)),
        Array(a) => {
            let mut list = Vec::with_capacity(a.len());
            for value in a {
                list.push(convert_value(value, env)?)
            }
            Ok(list.encode(env))
        }
        Integer(i) => Ok(i.encode(env)),
        Float(f) => {
            if f.is_infinite() {
                if f.is_sign_positive() {
                    Ok(atoms::infinity().encode(env))
                } else {
                    Ok(atoms::negative_infinity().encode(env))
                }
            } else if f.is_nan() {
                if f.is_sign_positive() {
                    Ok(atoms::nan().encode(env))
                } else {
                    Ok(atoms::negative_nan().encode(env))
                }
            } else {
                Ok(f.encode(env))
            }
        },
        Boolean(b) => Ok(b.encode(env)),
        Datetime(d) => {
            Ok((atoms::datetime(), d.to_string()).encode(env))
        },
    }
}
