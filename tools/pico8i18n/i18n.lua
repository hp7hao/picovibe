function _l(l)
	return 8*(l-1)
end

function _c(c)
	return 4*(c-1)
end

function _t(str,x,y,col)
	local s=texts[str]
	if x==nil then x=0 end
	if y==nil then y=0 end
	if col==nil then col=7 end
	c=#s/8
	for i=1,c do
		for j=1,8 do
			h=s[j+(i-1)*8]
			b=n2b(tonum(h,0x1))
			for k=1,4 do
				if b[k] == "1" then
					pset(x+4*(i-1)+k,y+j,col)
				end
			end
		end
	end
end

function n2b(num)
	local bin=""
	for i=0,3 do
	 bin=(band(num,2^i)\2^i)..bin
	end
	return bin
end