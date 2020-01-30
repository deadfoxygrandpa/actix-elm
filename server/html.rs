use serde::{Serialize};
use serde_json;


pub fn elm_page<T: ?Sized>(flags: &T) -> String 
where T: Serialize
{
	let flags_ = serde_json::to_string(flags).unwrap_or("null".to_string());

	format!("\
<!DOCTYPE html>\
<html>\
<head>\
<meta charset=\"utf-8\">\
<title>App</title>\
<script src=\"elm.js\"></script>\
</head>\
<body>\
<script>\
var app=Elm.Main.init({{flags:{f}}});\
</script>\
</body>\
</html>", f = flags_)
}