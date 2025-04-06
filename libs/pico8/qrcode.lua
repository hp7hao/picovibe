--qr code generator
--@ctinney94

--https://www.thonky.com/qr-code-tutorial

mode=4
--2 Alphanumeric
--4 Byte

printEC=false
printDataBits=false

function stringToArray(str)
	local a,l={},0
	while l<#str do
		l+=1
		if sub(str,l,l)=="," then
			local s=sub(str,1,l-1)
			if s=="true" then
				add(a,true)
			elseif s=="false" then
				add(a,false)
			else
			n=tonum(s)
			if n==null then
				add(a,s)
			else
				add(a,n)
			end
			end
		str,l=sub(str,l+1),0
		end
	end
	return a
end

-->8
-------------------------------helpers------------------------------------------

function integerToBinary(binaryValue,totalBits)
    --Source https://www.lexaloffle.com/bbs/?tid=27657
    local result,a="",0
    for i = 0,totalBits-1 do
     result=band(2^i,binaryValue)/2^i..result
    end
    return result
  end
  
  function getAlphanumericCharacterValue(character)
   if (character=="") return 0
   local values="0123456789abcdefghijklmnopqrstuvwxyz $%*+-./:"
   local result=1
   while character != sub(values,result,result) do
    result+=1
   end
   return result-1
  end
  
  function getIntegerValueForUTF8Character(character)
    if (character=="" or character==null) return null
    local values=" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    local result=1
    while character != sub(values,result,result) do
     result+=1
    end
    return result+31
   end
   --------------------------QR code functions------------------------------------
  
  function makeqrcode(dataToEncode, x, y)
   -- 设置默认值为0
   x = x or 0
   y = y or 0
   
   --let's also go with the L error correction level (7% of data can be lost and still readable)
   local dataSize = #dataToEncode --* 1.07
   local version = 0
   if mode==2 then
     version = findMinimumQrCodeVersionRequiredForLLevelErrorCorrectionOfAlphanumericData(dataSize)
   else
     version = findMinimumQrCodeVersionRequiredForLLevelErrorCorrectionOfByteData(dataSize)
   end
  
   local encodedData = encodeDataAsBinaryString(dataToEncode, version)
   local errorCorrectionCodewords = generateErrorCorrectionCodeWords(version, encodedData)
  
    --for larg message, data interweaving data here (yuck, sounds hard!)
    local dataBits=encodedData..errorCorrectionCodewords
  
    if printDataBits then
      for i=1,#dataBits,8 do
       ?tonum("0b"..sub(dataBits,i,i+7))
      end
      stop()
    end
  
    local cornerPosition=(((version-1)*4)+21) - 7
  
    placeFixedPatterns(version,cornerPosition, x, y)
    placeDataBits(dataBits,cornerPosition, x, y)
  
    local optimalMask = findAndApplyBestDataMask(cornerPosition, x, y)
    local formatInfoString = calculateFormattingInformation(optimalMask)
    placeFormatString(formatInfoString,cornerPosition, x, y)

    -- 添加阴影线
    local width = cornerPosition + 7
    -- 右边阴影线
    line(x+width,y+1,x+width,y+width,14)
    -- 底边阴影线
    line(x+1,y+width,x+width,y+width,14)
  end
  
  --------------------------------Formating info----------------------------------
  
  function calculateFormattingInformation(maskPattern)
    --this would typically be 01 but we'll be removing any zeros to the left
    -- in a moment anyway, so just don't bother to put one in here instead
    local errorCorrectionLLevelBits="1"
    --using 7 currently for example, but this will need to be changed
    local maskPatternBits = integerToBinary(maskPattern,3)
    local formatString=errorCorrectionLLevelBits..maskPatternBits.."0000000000"
    while #(formatString.."") > 10 do
      local generatorPolynomial = "10100110111"
      --pad generator polynomial to make it the same length as the error errorCorrectionBits
      while #generatorPolynomial < #formatString do
        generatorPolynomial = generatorPolynomial.."0"
      end
  
      formatString=bxor("0b"..formatString,"0b"..generatorPolynomial)
      formatString=integerToBinary(formatString,#generatorPolynomial)
      while sub(formatString,1,1)=="0" do
        formatString=sub(formatString,2,#formatString)
      end
    end
    while #formatString < 10 do
      formatString="0"..formatString
    end
    formatString="0"..errorCorrectionLLevelBits..maskPatternBits..formatString
    typeInformationBits={
      "0b111011111000100",  --0
      "0b111001011110011",  --1
      "0b111110110101010",  --2
      "0b111100010011101",  --3
      "0b110011000101111",  --4
      "0b110001100011000",  --5
      "0b110110001000001",  --6
      "0b110100101110110"  --7
    }
    formatString=bxor("0b"..formatString,typeInformationBits[maskPattern+1])
    local test = sub(typeInformationBits[maskPattern],3,17)
    return test
    --return integerToBinary(formatString,15)
  end
  
  function placeFormatString(formatInfoString,cornerPosition, x, y)
    --invert bits so we don't draw pixels with value of 0 as black
    formatInfoString = integerToBinary(bnot("0b"..formatInfoString),15)
  
    for i=1,6 do
      local c = tonum(sub(formatInfoString,i,i))*7
      pset(x+i-1,y+8,c)
    end
    pset(x+7,y+8,tonum(sub(formatInfoString,7,7))*7)
    pset(x+8,y+8,tonum(sub(formatInfoString,8,8))*7)
    pset(x+8,y+7,tonum(sub(formatInfoString,9,9))*7)
    for i=1,7 do
      local c = tonum(sub(formatInfoString,i,i))*7
      pset(x+8,y+cornerPosition+7-i,c)
    end
    for i=8,15 do
      local c = tonum(sub(formatInfoString,i,i))*7
      pset(x+cornerPosition-9+i,y+8,c)
    end
    for i=10,15 do
      local c = tonum(sub(formatInfoString,i,i))*7
      pset(x+8,y+15-i,c)
    end
  end
  
  --------------------------------Data masking------------------------------------
  
  function findAndApplyBestDataMask(cornerPosition, x, y)
    memcpy(0,0x6000,4096)
    cls(8)
    local masks={
      function(x,y)
        return (x+y)%2==0
      end,
      function(x,y)
        return y%2==0
      end,
      function(x,y)
        return x%3==0
      end,
      function(x,y)
        return (x+y)%3==0
      end,
      function(x,y)
        return (flr(y/2)+flr(x/3))%2==0
      end,
      function(x,y)
        return ((x*y)%2)+((x*y)%3)==0
      end,
      function(x,y)
        return ((x*y)%2)+((x*y)%3)%2==0
      end,
      function(x,y)
        return (((x+y)%2)+((x*y)%3))%2 == 0
      end
    }
    palt(0,false)
    sspr(0,0,128,128)
  
    -- 使用固定的掩码模式 0 替代随机选择
    local mask = 1
  
    for _x=0,cornerPosition+6 do
      for _y=0,cornerPosition+6 do
        local c = pget(_x+x,_y+y)
        if c>7 then
          local flip = masks[mask](_x,_y)
          if c==8 and flip then
            c=15
          elseif c==15 and flip then
            c=8
          end
          pset(_x+x,_y+y,c-8)
        end
      end
    end
    return mask
  end
  
  ---------------------------Module placement matrix------------------------------
  
  function placeFixedPatterns(version, cornerPosition, x, y)
    rectfill(x,y,x+cornerPosition+6,y+cornerPosition+6,3)
    reserveFormatInformationArea(cornerPosition, x, y)
    placeTimingPatterns(cornerPosition, x, y)
    placeAllFinderPatterns(cornerPosition, x, y)
    placeSeperators(cornerPosition,7, x, y)
    --Add alignment patterns
    if version>1 then
      local placementArray=getAlignmentPatternLocations(version)
      for _x=6,placementArray[#placementArray],placementArray[2]-placementArray[1] do
       for _y=6,placementArray[#placementArray],placementArray[2]-placementArray[1] do
         if not((_x==6 and _y==6) or
               (_x==6 and _y==placementArray[#placementArray]) or
               (_y==6 and _x==placementArray[#placementArray])) then
          placeAlignmentPattern(_x+x,_y+y,0,7)
        end
       end
      end
    end
    placeDarkModule(version, x, y)
    if (version>6) reserveVersionInformationArea(cornerPosition, x, y)
  end
  
  function placeDataBits(dataBits,cornerPosition, x, y)
    local index,_x=1,cornerPosition+6
    local upwardDirection=true
    while _x>-1 do
      for _y=cornerPosition+6,0,-1 do
        if (not upwardDirection) _y=cornerPosition+6-_y
        if (_x==6) _x-=1
        for __x=_x,_x-1,-1 do
          local c=tonum(sub(dataBits,index,index))
          if pget(__x+x,_y+y)==3 and c!=null then
            c=abs(c-1)
            pset(__x+x,_y+y,(c*7)+8)
            index+=1
          elseif c == null and pget(__x+x,_y+y)==3 then
            pset(__x+x,_y+y,15)
          end
        end
      end
      _x-=2
      upwardDirection=not upwardDirection
    end
  end
  
  function placeTimingPatterns(cornerPosition, x, y)
    fillp(0xa5a5)
    line(x+6,y,x+6,y+cornerPosition,7)
    line(x,y+6,x+cornerPosition,y+6,7)
    fillp()
  end
  
  function placeAllFinderPatterns(cornerPosition, x, y)
    placeFinderPattern(x,y,0,7)
    placeFinderPattern(x+cornerPosition,y,0,7)
    placeFinderPattern(x,y+cornerPosition,0,7)
  end
  
  function placeFinderPattern(x,y,c1,c2)
    rectfill(x,y,x+6,y+6,c1)
    rectfill(x+1,y+1,x+5,y+5,c2)
    rectfill(x+2,y+2,x+4,y+4,c1)
  end
  
  function placeSeperators(cornerPosition,c, x, y)
    line(x,y+7,x+7,y+7,c)
    line(x+7,y,x+7,y+7,c)
    line(x+cornerPosition-1,y+7,x+cornerPosition+6,y+7,c)
    line(x+cornerPosition-1,y,x+cornerPosition-1,y+7,c)
    line(x+7,y+cornerPosition-1,x+7,y+cornerPosition+6,c)
    line(x,y+cornerPosition-1,x+7,y+cornerPosition-1,c)
  end
  
  function placeAlignmentPattern(x,y,c1,c2)
    rect(x-2,y-2,x+2,y+2,c1)
    rect(x-1,y-1,x+1,y+1,c2)
    pset(x,y,c1)
  end
  
  function getAlignmentPatternLocations(version)
     return ({
        {6,18},
        {6,22},
        {6,26},
        {6,30},
        {6,34},
        {6,22,38},
        {6,24,42},
        {6,26,46}
     })[version-1]
  end
  
  function placeDarkModule(version, x, y)
    pset(x+8,y+(4*version) + 9,0)
  end
  
  function reserveFormatInformationArea(cornerPosition, x, y)
    line(x,y+8,x+8,y+8,1)
    line(x+8,y,x+8,y+8,1)
    line(x+8,y+cornerPosition-1,x+8,y+cornerPosition+6,1)
    line(x+cornerPosition-1,y+8,x+cornerPosition+6,y+8,1)
  end
  
  function reserveVersionInformationArea(cornerPosition, x, y)
    rectfill(x,y+cornerPosition-2,x+5,y+cornerPosition-4,11)
    rectfill(x+cornerPosition-2,y,x+cornerPosition-4,y+5,11)
  end
  ------------------------------Data encoding-------------------------------------
  
  function encodeDataAsBinaryString(dataToEncode, version)
   local modeIndicator = integerToBinary(mode,4)
   local originalInputLengthInBinary = integerToBinary(#dataToEncode,8)
   local encodedData = modeIndicator..originalInputLengthInBinary
  
   if mode==2 then
    encodedData=encodedData..encodeAlphaNumericStringToBinary(dataToEncode)
   else
     encodedData=encodedData..encodeUTF8StringAsBinary(dataToEncode)
   end
  
   local requiredDataLength = findTotalNumberOfDataCodewordsForVersion(version)*8
   local paddingRequired = requiredDataLength - #encodedData
   encodedData=encodedData.."0000"
   local additionalPaddingRequiredToMakeEncodedDataLengthAMultipleOf8=#encodedData%8
   if additionalPaddingRequiredToMakeEncodedDataLengthAMultipleOf8!=0 then
    for i=0,7-additionalPaddingRequiredToMakeEncodedDataLengthAMultipleOf8 do
     encodedData=encodedData.."0"
    end
   end
  
   local bool236or17=true
   while #encodedData < requiredDataLength do
    if (bool236or17) encodedData=encodedData.."11101100"--236
    if (not bool236or17) encodedData=encodedData.."00010001"--17
    bool236or17=not bool236or17
   end
  
   return encodedData
  end
  
  function findMinimumQrCodeVersionRequiredForLLevelErrorCorrectionOfAlphanumericData(dataSize)
   --values here going from version 1 to 7
   local upperLimits={25,47,77,114,154,195,224}
   local optimalVersion=1
  
   if dataSize > upperLimits[#upperLimits] then
    ?"data is too big!"
    stop()
   end
  
   while dataSize > upperLimits[optimalVersion]do
    optimalVersion+=1
   end
   return optimalVersion
  end
  
  
  function findMinimumQrCodeVersionRequiredForLLevelErrorCorrectionOfByteData(dataSize)
   --values here going from version 1 to 7
   local upperLimits={17,32,53,78,106,134,154}
   local optimalVersion=1
  
   if dataSize > upperLimits[#upperLimits] then
    ?"data is too big!"
    return
   end
  
   while dataSize > upperLimits[optimalVersion]do
    optimalVersion+=1
   end
   return optimalVersion
  end
  
  
  --For L Error Correction level
  function findTotalNumberOfDataCodewordsForVersion(version)
   local valuesForMediumErrorCorrection={19,34,55,80,108,136,156,194,232}
   return valuesForMediumErrorCorrection[version]
  end
  
  function encodeUTF8StringAsBinary(dataToEncode)
    local encodedData=""
    for i=1,#dataToEncode do
      local character = sub(dataToEncode,i,i)
      local integerValue =
      getIntegerValueForUTF8Character(character)
      local binaryValue = integerToBinary(integerValue,8)
      encodedData=encodedData..binaryValue
    end
    return encodedData
  end
  
  function encodeAlphaNumericStringToBinary(dataToEncode)
   local encodedData=""
   for i=1,#dataToEncode,2 do
    local firstCharacterToBeEncoded = sub(dataToEncode,i,i)
    local secondCharacterToBeEncoded = sub(dataToEncode,i+1,i+1)
    if (secondCharacterToBeEncoded=="") then
     --encode final character as 6 bit binary string
     encodedData=encodedData..integerToBinary(getAlphanumericCharacterValue(firstCharacterToBeEncoded),6)
    else
     local twoCharactersToBeConvertedToBinary=
            getAlphanumericCharacterValue(firstCharacterToBeEncoded)*45
            + getAlphanumericCharacterValue(secondCharacterToBeEncoded)
     encodedData=encodedData..integerToBinary(twoCharactersToBeConvertedToBinary,11)
    end
   end
   return encodedData
  end
  
   --------------------------Error correction-------------------------------------
  
  function generateErrorCorrectionCodeWords(version, encodedData)
    local messagePolynomial={}
    for i=1,#encodedData,8 do
    --for i=1,21*8,8 do
     add(messagePolynomial,tonum("0b"..sub(encodedData,i,i+7)))
     --?((i-1)/8)..": "..tonum("0b"..sub(encodedData,i,i+7))
    end
    --instead of generating the error correction polynomials
    -- we'll instead fetch the results from a list since maths is hard and life's too short
    originalErrorCorrectionPolynomial = getPreGeneratedPolynomialForErrorCorrectionLevelLForVersion(version)
  
    errorCorrectionPolynomial={}
    for a in all(originalErrorCorrectionPolynomial) do
      add(errorCorrectionPolynomial,a)
    end
  
    local errorCorrectionCodeWordsForGroup1={7,10,15,20,26}
    local totalDivisionStepsRequired=#messagePolynomial
  
    --make sure lead term for each polynomial exponent is the same
    for i=2,#messagePolynomial do
      add(errorCorrectionPolynomial,0)
    end
    for i=1,errorCorrectionCodeWordsForGroup1[version] do
      add(messagePolynomial,0)
    end
   local useMeforDivision=messagePolynomial
   for j=1,totalDivisionStepsRequired do
    for i=1,#errorCorrectionPolynomial do
      if i<#originalErrorCorrectionPolynomial+1 then
        errorCorrectionPolynomial[i]=(getAlphaNotationValueForDecimal(useMeforDivision[1])+originalErrorCorrectionPolynomial[i])%255
        errorCorrectionPolynomial[i]=bxor(getDecimalValueForAlphaNotation(errorCorrectionPolynomial[i]),useMeforDivision[i])
      else
        errorCorrectionPolynomial[i]=bxor(0,useMeforDivision[i])
      end
    end
    useMeforDivision={}
    while (errorCorrectionPolynomial[1]==0) do
      del(errorCorrectionPolynomial,errorCorrectionPolynomial[1])
    end
    for a in all(errorCorrectionPolynomial) do
      add(useMeforDivision,a)
    end
   end
   if printEC then
     ?#errorCorrectionPolynomial
     for i=1,#errorCorrectionPolynomial do
       ?#errorCorrectionPolynomial-i..": "..errorCorrectionPolynomial[i]
     end
     stop()
   end
  
   errorCorrectionCodewords=""
   for i=1,#errorCorrectionPolynomial do
     errorCorrectionCodewords=errorCorrectionCodewords..integerToBinary(tonum(errorCorrectionPolynomial[i]),8)
   end
   return errorCorrectionCodewords
  end
  
  function getPreGeneratedPolynomialForErrorCorrectionLevelLForVersion(version)
   --get codewords required for group 1
   local preGeneratedPolynomialForErrorCorrectionLevelL={
    {0,87,229,146,149,238,102,21},
    {0,251,67,46,61,118,70,64,94,32,45},
    {0,8,183,61,91,202,37,51,58,58,237,140,124,5,99,105},
    {0,17,60,79,50,61,163,26,187,202,180,221,225,83,239,156,164,212,188,190},
    {0,173,125,158,2,103,182,118,17,145,201,111,28,165,53,161,21,245,142,13,102,48,227,153,145,218,70}
   }
   return preGeneratedPolynomialForErrorCorrectionLevelL[version]
  end
  
  alphaLookup= stringToArray"0,1,25,2,50,26,198,3,223,51,238,27,104,199,75,4,100,224,14,52,141,239,129,28,193,105,248,200,8,76,113,5,138,101,47,225,36,15,33,53,147,142,218,240,18,130,69,29,181,194,125,106,39,249,185,201,154,9,120,77,228,114,166,6,191,139,98,102,221,48,253,226,152,37,179,16,145,34,136,54,208,148,206,143,150,219,189,241,210,19,92,131,56,70,64,30,66,182,163,195,72,126,110,107,58,40,84,250,133,186,61,202,94,155,159,10,21,121,43,78,212,229,172,115,243,167,87,7,112,192,247,140,128,99,13,103,74,222,237,49,197,254,24,227,165,153,119,38,184,180,124,17,68,146,217,35,32,137,46,55,63,209,91,149,188,207,205,144,135,151,178,220,252,190,97,242,86,211,171,20,42,93,158,132,60,57,83,71,109,65,162,31,45,67,216,183,123,164,118,196,23,73,236,127,12,111,246,108,161,59,82,41,157,85,170,251,96,134,177,187,204,62,90,203,89,95,176,156,169,160,81,11,245,22,235,122,117,44,215,79,174,213,233,230,231,173,232,116,214,244,234,168,80,88,175,0"
  function getAlphaNotationValueForDecimal(value)
    --Pico 8 has no log() function, nor does it handle large numbers well
    -- therefore a horrid lookup table is best scenario here
    return alphaLookup[value]
  end
  
  decimalLookup= stringToArray"1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1,0"
  function getDecimalValueForAlphaNotation(alphaNotationExponent)
    return decimalLookup[alphaNotationExponent+1]
  end