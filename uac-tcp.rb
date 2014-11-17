require 'quaff'

STANDARD_SDP = "v=0\r
o=- 3547439529 3547439529 IN IP4 0.0.0.0\r
s=-\r
c=IN IP4 0.0.0.0\r
t=0 0\r
m=audio 6000 RTP/AVP 8 0\r
a=rtpmap:8 PCMA/8000\r
a=rtpmap:101 telephone-event/8000\r
a=fmtp:101 0-11,16\r
"

callerstack = (7000000001..7000000500).to_a
calleestack = (7000000501..7000001000).to_a

def single_caller(num1, num2)
  phone = Quaff::TCPSIPEndpoint.new("sip:#{num1}@demo.clearwater", "#{num1}@demo.clearwater", "7kkzTyGW", :anyport, "demo.clearwater")
  phone.register
  call = phone.outgoing_call("sip:#{num2}@demo.clearwater")
  call.send_request("INVITE", STANDARD_SDP, {"Content-Type" => "application/sdp"})
  #call.send_request("INVITE")
  call.recv_response("100")
  call.recv_response("180")
  call.recv_response_and_create_dialog("200")
  #call.recv_response("200")
  call.new_transaction
  call.send_request("ACK")
  sleep 3
  call.new_transaction
  call.send_request("BYE")
  call.recv_response("200")
  puts "Successful call!\n"
  call.end_call
  phone.unregister
end

t_pool = []
for i in 0..400 do
  t = Thread.new{single_caller(callerstack.pop, calleestack.pop)}
  t_pool.push(t)
end

for t in t_pool do
  t.join
end
