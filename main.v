module main

import xiusin.vredis
import veb

pub struct Context {
	veb.Context
}

pub struct App {
	pub:
		key string
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.text('Hello from veb $app.key')
}

fn main() {
	mut redis := vredis.new_client(host: '127.0.0.1', port: 6379) or {
		panic(err)
	}

	redis.set("mykey", "hello") or {
		panic(err)
	}

	result := redis.get("mykey") or {
		panic(err)
	}

	mut app := &App{
		key: result
	}
	veb.run[App, Context](mut app, 8000)

	redis.close() or {
		panic(err)
	}
}
