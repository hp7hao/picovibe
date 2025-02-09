function _t(str,x,y,fgc,bgc)
	fgc=fgc or 7
	bgc=bgc or 0
	local hex=texts[str]
	local bs=h2b(hex)
	-- print(bs)
	local px=x
	local py=y
	local i=1
	while i<=#bs do
		if sub(bs,i,i+3)=="0000" then
			i=i+4
			-- ascii character
			local w=tonum("0b"..sub(bs,i,i+3));i=i+4
			local h=tonum("0b"..sub(bs,i,i+3));i=i+4
			if px+w>127 then
				px=x
				py=py+9
			end
			for j=1,h do
				for k=1,w do
					if bs[i+(j-1)*w+k-1]=='1' then
						pset(px+k,py+j,fgc)
					else
						pset(px+k,py+j,bgc)
					end
				end
			end
			i=i+w*h
			px=px+w
		elseif sub(bs,i,i+3)=="0001" then
			i=i+4
			-- utf8 character, 8x8
			if px>119 then
				px=x
				py=py+9
			end
			for j=1,8 do
				for k=1,8 do
					if bs[i+(j-1)*8+k-1]=='1' then
						pset(px+k,py+j,fgc)
					else
						pset(px+k,py+j,bgc)
					end
				end
			end
			i=i+64
			px=px+8
		elseif sub(bs,i,i+3)=="0010" then
			i=i+4
			-- new line
			px=x
			py=py+9
		elseif sub(bs,i,i+3)=="1111" then
			break
		end
	end
end

function h2b(h)
	local bs=""
	for i=1,#h do
		bs=bs..n2b(tonum(sub(h,i,i),"0x1"))
	end
	return bs
end

function n2b(num)
	local bin=""
	for i=0,3 do
	 bin=(band(num,2^i)\2^i)..bin
	end
	return bin
end
