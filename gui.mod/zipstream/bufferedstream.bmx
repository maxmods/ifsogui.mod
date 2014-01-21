'Strict

Rem
bbdoc: 	Buffered Stream
End Rem
'Module koriolis.bufferedstream

'ModuleInfo "Version: 1.0"
'ModuleInfo "Author: Régis JEAN-GILLES (Koriolis)"
'ModuleInfo "License: Public Domain"

'Import brl.stream

Public


Type TBufferedStream Extends TStream
	Field innerStream:TStream
	Field pos_%, start_%, end_%
	Field buf:Byte[]
	Field bufPtr:Byte Ptr
	Field bias1%
	Field bias2%
	
		
	Method Pos:Int()
		Return pos_
	End Method

	Method Size:Int()
		Return innerStream.Size()
	End Method

	Method Seek:Int(pos:Int)
		pos_ = pos
		If pos_ < start_ Then
			start_ = Max(pos_ - bias1, 0)
			innerStream.Seek(start_)
			end_ = start_ + innerStream.Read(bufPtr, buf.Length)
		ElseIf pos_ > end_ Then
			start_ = pos_ - bias2
			innerStream.Seek(start_)
			end_ = start_ + innerStream.Read(bufPtr, buf.Length)
		EndIf
		Return pos_
	End Method

	Method Read:Int(dst:Byte Ptr, count:Int)
		' NOTE: no doubt it could be optimized further, but hey, if it works
		Local initialPos% = pos_
		Assert pos_ >= start_ And pos_ <= end_ Else "Invalid position (" + pos_ + ", should be in [" + start_ + "," + end_ + "] )"
		Assert count >= 0 Else "Negative count"
		Repeat
			
			Assert(pos_ >= start_ And pos_ <= end_)
			If count <= end_-pos_ Then
				' All data already in the buffer, copy it and return
				MemCopy(dst, bufPtr+(pos_-start_), count)
				pos_ :+ count
				Return pos_ - initialPos
			Else
				If end_-pos_ > 0 Then
					MemCopy(dst, bufPtr + (pos_ - start_), end_ - pos_)
					count :- end_-pos_
					dst :+ end_-pos_
					pos_ = end_
					start_ = end_
				EndIf
					
				Local readBytes:Int
				If count >= buf.Length Then
					' Read data right into the target buffer
					readBytes = innerStream.Read(dst, buf.Length)
					dst:+readBytes
					pos_ :+ readBytes
					start_ = pos_
					end_ = pos_
					count :- readBytes
					If readBytes < buf.Length Then
						' The underlying stream couldn't read everything, so we  return
						Return pos_ - initialPos
					EndIf
				Else
					' Read more data into temp buffer
					start_ = pos_
					
					readBytes = innerStream.Read(bufPtr, buf.length)
					end_ = pos_ + readBytes
					' Copy data to target buffer
					Local cnt% = Min(count, readBytes)
					MemCopy(dst, bufPtr, cnt)
					pos_ :+ cnt
					count :- cnt
					dst :+ cnt
					Return pos_ - initialPos
				EndIf
			EndIf
		Forever
	End Method

	Method Write:Int(buf:Byte Ptr, count:Int)
		RuntimeError "Stream is not writeable"
		Return 0	
	End Method

	Method Flush:Int()
		Return innerStream.Flush()
	End Method

	Method Close:Int()
		Return innerStream.Close()
	End Method
End Type

Rem
bbdoc: 	Creates and return a buffered stream from around an existing stream (or url). 
		If the stream to wrap is already a buffered stream, returns the stream unchanged 
		(unless you set bForce to True).
		To change the size of the buffer, modify the value of bufSize (specified in bytes).
		Making the buffer bigger can enhance performance, at the expense of memory consumption.
EndRem
Function CreateBufferedStream:TStream(url:Object, bufSize%=4096, bForce%=False)
	Local stream:TStream = TStream(url)
	If stream = Null Then
		stream = ReadStream(url)
	EndIf
	If stream = Null Then
		Return Null
	ElseIf TBufferedStream(stream) = Null Then
		Return CreateBufferedStreamImpl(stream, bufSize)
	Else
		Return stream
	EndIf
End Function

Private

Function CreateBufferedStreamImpl:TBufferedStream(innerStream:TStream, bufSize%=8192)
	If bufSize < 1024 Then
		bufSize = 1024
	EndIf
	Local s:TBufferedStream = New TBufferedStream
	s.innerStream = innerStream
	s.buf = New Byte[bufSize]
	s.bufPtr = s.buf
	s.bias1 = (s.buf.Length/3)*2
	s.bias2 = (s.buf.Length/3)
	s.pos_ = innerStream.Pos()
	
	Return s
End Function

Type TBufferedStreamFactory Extends TStreamFactory
	Method CreateStream:TStream (url:Object, proto:String, path:String, readable:Int, writeable:Int)
		If proto="buf" And writeable = False
			Local innerStream:TStream = ReadStream(path)
			If innerStream <> Null Then
				Return CreateBufferedStream(innerStream)
			EndIf
		EndIf
	End Method
End Type

New TBufferedStreamFactory
