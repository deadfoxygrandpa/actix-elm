use serde::{Serialize};
use serde_json;

const NULL: &str = "null";

pub fn elm_page<T: ?Sized>(flags: &T) -> String 
where T: Serialize
{
	let flags_ = serde_json::to_string(flags).unwrap_or(NULL.to_string());

	format!("\
<!DOCTYPE html>\
<html>\
<head>\
<meta charset=\"utf-8\">\
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\
<title>App</title>\
<link href=\"style.css\" rel=\"stylesheet\">\
<script src=\"elm.js\"></script>\
</head>\
<body class=\"bg-gray-100\">\
<script>\
var app=Elm.Main.init({{flags:{f}}});\
</script>\
</body>\
</html>", f = flags_)
}