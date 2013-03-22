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
    token :URL, /\/[A-Za-z0-9\-_\/.@]+/
    
    literals '<{}[],:'
    ignore " \t"
    
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
  
  rule 'requests : requests request | request' do |requests, *requests_array|
    requests.value = requests_array.map(&:value).flatten
  end
  
  rule 'request : VERB URL optional_contexts' do |request, verb, url, optional_contexts|
    request.value = Request.new do |r|
      r.verb     = verb.value
      r.url      = url.value
      r.contexts = optional_contexts.value unless optional_contexts.value.nil?
    end
  end
  
  rule 'optional_contexts : contexts | empty' do |optional_contexts, contexts|
    optional_contexts.value = contexts.value
  end
  
  rule 'contexts : contexts context | context' do |contexts, *contexts_array|
    contexts.value = contexts_array.map { |c| Context.new(c.value) }
  end
  
  rule 'context : context context_part | context_part' do |context, *context_parts|
    context.value = context_parts.map(&:value).inject(:merge)
  end
  
  rule 'context_part : request_body | response_code' do |context_part, part|
    context_part.value = part.value
  end
  
  rule 'request_body : json' do |request_body, json|
    request_body.value = { request_body: json.value }
  end
  
  rule 'response_code : "<" NUMBER' do |response_code, _, number|
    response_code.value = { response_code: number.value }
  end
  
  rule('empty :') { }
  
  rule 'json : json_object | json_array' do |json, object_or_array|
    json.value = Oj.dump(object_or_array.value)
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
  
  rule 'json_string : JSON_STRING' do |json_string, string|
    json_string.value = string.value
  end
end
