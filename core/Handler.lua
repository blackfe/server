local Handler = {}

function Handler:ctor(parm)
   self.fd = parm.fd
   self.cmds = {}
   self.requests = {}
   self.responses = {}
end

function Handler:register(CMD,REQUEST,RESPONSE)
   for k,v in pairs(self.cmds) do
      assert(CMD.k == nil , "Command already registed")

      CMD.k = handler(self,v)
   end

   for k,v in pairs(self.requests) do
      assert(REQUEST.k == nil, "Request already registed")
      REQUEST.k = handler(self,v)
   end

   for k,v in pairs(self.responses) do
      assert(RESPONSE.k == nil, "Response already registed")
      RESPONSE.k = handler(self,v)
   end
end

function Handler:pushMethod(tbl,method)
   tbl[method] = handler(self,self[method])
end


return Handler
