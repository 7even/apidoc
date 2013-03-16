class Parser < Rly::Yacc
  lexer do
    token :VERB, /GET|POST|PUT|PATCH|DELETE/
    token :URL, /\/[A-Za-z0-9\-_\/.]+/
    
    ignore " \t\n"
  end
  
  rule 'requests : requests request | request' do |requests, *requests_array|
    requests.value = requests_array.map(&:value).flatten
  end
  
  rule 'request : VERB URL' do |request, verb, url|
    request.value = Request.new(verb: verb.value, url: url.value)
  end
end
