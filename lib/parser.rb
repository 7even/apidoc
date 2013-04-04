class Parser < Rly::Yacc
  lexer do
    token :NUMBER, /\d+/ do |t|
      t.value = t.value.to_i
      t
    end
    
    token :VERB,  /GET|POST|PUT|PATCH|DELETE/
    token :TRUE,  /true/
    token :FALSE, /false/
    token :NULL,  /null/
    
    token :JSON_STRING, /"([^"\\]|\\["\\\/nbfnrt]|\\u\d{4})+"/ do |t|
      t.value = t.value[1..-2] # cut the quotes off
      # TODO: replace \n with a newline, \r with a carriage return etc
      t
    end
    
    token :URL, /\/[A-Za-z0-9\-_\/.@:]+/
    # param1=value1&param2=value2&param3[]=value3&param3[]=value4
    token :QUERY_STRING, /[A-Za-z0-9@.\[\]]+=[A-Za-z0-9@.]+(&[A-Za-z0-9@.\[\]]+=[A-Za-z0-9@.]+)*/
    token :STRING, /[A-Za-z0-9\-_\/.@]+/
    
    literals '><{}[],:#'
    ignore " \t\r"
    
    token /\n+/ do |t|
      t.lexer.lineno += t.value.count("\n")
      t
    end
    
    on_error do |t|
      puts "Illegal character #{t.value.inspect} at line #{t.lexer.lineno + 1}"
      t.lexer.pos += 1
      nil
    end
  end
  
  rule 'blueprint : requests' do |blueprint, requests|
    blueprint.value = Blueprint.new(requests: requests.value)
  end
  
  rule 'requests : requests request | request' do |requests, *requests_array|
    requests.value = requests_array.map(&:value).flatten
  end
  
  rule 'request : VERB URL contexts' do |request, verb, url, contexts|
    request.value = Request.new do |r|
      r.verb     = verb.value
      r.url      = url.value
      r.contexts = contexts.value
    end
  end
  
  rule 'contexts : contexts context | context | empty' do |contexts, *contexts_array|
    contexts.value = contexts_array.map(&:value).flatten
  end
  
  rule 'context : request_context response_context' do |context, request_context, response_context|
    context_attributes = [request_context, response_context].map(&:value).compact.inject(:merge)
    context.value = Context.new(context_attributes)
  end
  
  rule 'request_context : request_query_params request_headers request_body_params
                        | request_query_params request_headers
                        | request_query_params request_body_params
                        | request_headers request_body_params
                        | request_query_params
                        | request_headers
                        | request_body_params
                        | empty' do |request_context, *request_context_parts|
    request_context.value = request_context_parts.map(&:value).compact.inject(:merge)
  end
  
  rule 'response_context : response_code response_headers response_body_params
                         | response_code response_headers
                         | response_code response_body_params
                         | response_headers response_body_params
                         | response_code
                         | response_headers
                         | response_body_params
                         | empty' do |response_context, *response_context_parts|
    response_context.value = response_context_parts.map(&:value).compact.inject(:merge)
  end
  
  rule 'request_query_params : ">" QUERY_STRING' do |request_query_params, _, query_string|
    request_query_params.value = { request_query_params: Rack::Utils.parse_nested_query(query_string.value) }
  end
  
  rule 'request_headers : request_headers_array' do |request_headers, request_headers_array|
    request_headers.value = { request_headers: request_headers_array.value }
  end
  
  rule 'request_headers_array : request_headers_array request_header | request_header' do |request_headers_array, *headers_array|
    request_headers_array.value = headers_array.map(&:value).inject(:merge)
  end
  
  rule 'request_header : ">" header' do |request_header, _, header|
    request_header.value = header.value
  end
  
  rule 'request_body_params : ">" json' do |request_body_params, _, json|
    request_body_params.value = { request_body_params: json.value }
  end
  
  rule 'response_code : "<" NUMBER' do |response_code, _, number|
    response_code.value = { response_code: number.value }
  end
  
  rule 'response_headers : response_headers_array' do |response_headers, response_headers_array|
    response_headers.value = { response_headers: response_headers_array.value }
  end
  
  rule 'response_headers_array : response_headers_array response_header | response_header' do |response_headers_array, *headers_array|
    response_headers_array.value = headers_array.map(&:value).inject(:merge)
  end
  
  rule 'response_header : "<" header' do |response_header, _, header|
    response_header.value = header.value
  end
  
  rule 'response_body_params : "<" json' do |response_body_params, _, json|
    response_body_params.value = { response_body_params: json.value }
  end
  
  rule 'header : STRING ":" STRING' do |header, header_name, _, header_value|
    header.value = { header_name.value => header_value.value }
  end
  
  rule('empty :') { }
  
  rule 'json : json_object | json_array' do |json, object_or_array|
    json.value = object_or_array.value
  end
  
  rule 'json_object : "{" json_key_value_pairs "}"' do |json_object, _, json_key_value_pairs, _|
    json_object.value = json_key_value_pairs.value
  end
  
  rule 'json_key_value_pairs : json_key_value_pairs "," json_key_value_pair' do |json_key_value_pairs, key_value_pairs, _, key_value_pair|
    json_key_value_pairs.value = key_value_pairs.value.merge(key_value_pair.value)
  end
  
  rule 'json_key_value_pairs : json_key_value_pair' do |json_key_value_pairs, key_value_pair|
    json_key_value_pairs.value = key_value_pair.value
  end
  
  rule 'json_key_value_pair : json_string ":" json_value' do |json_key_value_pair, json_string, _, json_value|
    json_key_value_pair.value = { json_string.value => json_value.value }
  end
  
  rule 'json_array : "[" json_values "]"' do |json_array, _, json_values, _|
    json_array.value = json_values.value
  end
  
  rule 'json_values : json_values "," json_value' do |json_values, values, _, value|
    json_values.value = values.value << value.value
  end
  
  rule 'json_values : json_value' do |json_values, value|
    json_values.value = [value.value]
  end
  
  rule 'json_value : json_string | NUMBER | json_object | json_array | TRUE | FALSE | NULL' do |json_value, value|
    json_value.value = value.value
  end
  
  rule 'json_string : JSON_STRING | json_variable' do |json_string, string|
    json_string.value = string.value
  end
  
  rule 'json_variable : "#" "{" STRING "}"' do |json_variable, _, _, variable_name, _|
    json_variable.value = '#{' + variable_name.value + '}'
  end
end
