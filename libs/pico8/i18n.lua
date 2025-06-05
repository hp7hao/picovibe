i18n={}
i18n.lang=nil
i18n.texts={}

function _p(str,x,y,fc,bc)
	if #str==0 then return end
	local fgc=fc or 7
	local hex=i18n.texts[i18n.lang][str]
	local bs=h2b(hex)
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
						if bc then
							pset(px+k,py+j,bc)
						end
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
						if bc then
							pset(px+k,py+j,bc)
						end
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
	if not h then return "" end
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
