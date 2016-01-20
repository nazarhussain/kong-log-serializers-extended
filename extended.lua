local _M = {}

function _M.serialize(ngx)
  local authenticated_entity
  if ngx.ctx.authenticated_credential ~= nil then
    authenticated_entity = {
      id = ngx.ctx.authenticated_credential.id,
      consumer_id = ngx.ctx.authenticated_credential.consumer_id
    }
  end
  
  return {
    request = {
      uri = ngx.var.request_uri,
      request_uri = ngx.var.scheme.."://"..ngx.var.host..":"..ngx.var.server_port..ngx.var.request_uri,
      querystring = ngx.req.get_uri_args(), -- parameters, as a table
      method = ngx.req.get_method(), -- http method
      headers = ngx.req.get_headers(),
      size = ngx.var.request_length,
      body = (ngx.ctx.analytics.req_body or ""),
      post_args = (ngx.ctx.analytics.req_post_args or {})
    },
    response = {
      status = ngx.status,
      headers = ngx.resp.get_headers(),
      size = ngx.var.bytes_sent,
      body = (ngx.ctx.analytics.res_body or "")
    },
    latencies = {
      kong = (ngx.ctx.kong_processing_access or 0) +
             (ngx.ctx.kong_processing_header_filter or 0) +
             (ngx.ctx.kong_processing_body_filter or 0),
      proxy = ngx.var.upstream_response_time * 1000,
      request = ngx.var.request_time * 1000
    },
    authenticated_entity = authenticated_entity,
    api = ngx.ctx.api,
    client_ip = ngx.var.remote_addr,
    started_at = ngx.req.start_time() * 1000
  }
end

return _M