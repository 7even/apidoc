class Parser < Rly::Yacc
  lexer do
    token :VERB, /GET|POST|PUT|PATCH|DELETE/
    token :URL, /\/[A-Za-z0-9\-_\/.]+/
    literals '<{}'
    
    ignore " \t"
    
    token :NUMBER, /\d+/ do |t|
      t.value = t.value.to_i
      t
    end
    
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
  
  rule 'request : VERB URL contexts' do |request, verb, url, contexts|
    request.value = Request.new do |r|
      r.verb     = verb.value
      r.url      = url.value
      r.contexts = contexts.value
    end
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
  
  rule 'json : "{" "}"' do |json, *|
    # TODO: working json pattern
    json.value = ''
  end
end
