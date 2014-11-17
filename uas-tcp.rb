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

calleestack = (7000000501..7000001000).to_a

def single_callee(num1)
  phone = Quaff::TCPSIPEndpoint.new("sip:#{num1}@demo.clearwater", "#{num1}@demo.clearwater", "7kkzTyGW", :anyport, "demo.clearwater")
  phone.register
  call = phone.incoming_call

  call.recv_request("INVITE")
  call.send_response(100, "Trying")
  call.send_response(180, "Ringing")
  call.send_response("200", "OK", STANDARD_SDP, nil, {"Content-Type" => "application/sdp"})
  #call.send_response(200, "OK")
  call.recv_request("ACK")
  call.recv_request("BYE")
  call.send_response(200, "OK")
  call.end_call
  puts "Call was successful!\n"
  phone.unregister
end

t_pool = []
for i in 0..400 do
  t = Thread.new{single_callee(calleestack.pop)}
  t_pool.push(t)
end

for t in t_pool do
  t.join
end
