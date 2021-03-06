require 'ffi'

ENV['PATH'] = File.expand_path("../../../bin", __FILE__) + File::PATH_SEPARATOR + ENV['PATH']

module Gale
  # Directly exposes galefile.dll to Ruby
  module Dll
    extend FFI::Library

    ffi_lib 'galefile'
    ffi_convention :stdcall

    # Sensible size for string buffer.
    STRING_BUFFER_SIZE = 256

    TRUE = 1

    # Returned by #last_error (ggGetLastError)
    module Error
      NONE = 0
      FILE_NOT_FOUND = 1      # File does not exist.
      BAD_FORMAT = 2          # File format is invalid.
      CANNOT_BE_CLOSED = 3    # File can not be closed.
      INVALID_ADDRESS = 4     # The address of gale object is invalid.
      PARAMETER_INVALID = 5   # Parameter is invalid.
    end
    
    # Passed to #info (ggGetInfo)
    module Info
      BACKGROUND_COLOR = 1      # Return value is background-color.
      PALETTE_SINGLE = 2        # If the palette is single, return value is 1.
      TRANSPARENCY_DISABLED = 3 # If the transparency of bottom layer is disabled, return value is 1.
      BPP = 4                   # Return value is bpp(1,4,8,15,16,24).
      WIDTH = 5                 # Return value is width of image by pixel.
      HEIGHT = 6                # Return value is height of image by pixel.
    end

    # Passed to #frame_info (ggGetFrameInfo)
    module FrameInfo
      TRANSPARENT_COLOR = 1 # Return value is the transparent color.
      DELAY_MS = 2 # Return value is the delay by milli-second.
      DISPOSAL = 3 # Return value is the disposal type after display.

      # Returned by #frame_info (ggGetFrameInfo)
      module Disposal
        NOT_SPECIFIED = 0 # Not specified.
        NOT_DISPOSED = 1 # Not disposed.
        BACKGROUND_FILL = 2 # Filled by the background-color.
        RESTORE_PREVIOUS = 3 # Restored to previous state.
      end
    end

    # Passed to #layer_info (ggGetLayerInfo)
    module LayerInfo
      VISIBLE = 1           # If the layer is visible, return value is 1.
      TRANSPARENT_COLOR = 2 # Return value is the transparent color.
      OPACITY = 3           # Return value is the opacity(0~255).
      ALPHA_CHANNEL = 4     # If the alpha-channel is effective, return value is 1
    end

    # LPVOID __stdcall ggOpen(LPCSTR apath);
    # Opens a gal file.
    # @param Filename [String] of the gal file.
    # @return     If the function succeeds, the return value is the address of the gale object. The gale object must be deleted by ggClose. If the function fails, the return value is NULL.
    attach_function :open, :ggOpen, [:string], :pointer

    # LONG __stdcall ggClose(LPVOID pFile);
    # Deletes a gale object.
    # @param pFile The address of the gale object.
    # @return If the function succeeds, the return value is 1. If the function fails, the return value is 0.
    attach_function :close, :ggClose, [:pointer], :bool

    #DWORD __stdcall ggGetLastError(void);
    #Contents:   Retrieves the latest error code.
    #Parameters: Nothing.
    #Return:     Error code.
    #        1 = File does not exist.
    #        2 = File format is invalid.
    #        3 = File can not be closed.
    #        4 = The address of gale object is invalid.
    #        5 = Parameter is invalid.
    attach_function :last_error, :ggGetLastError, [], :uint

    # DWORD __stdcall ggGetFrameCount(LPVOID pFile);
    # Contents:   Retrieves number of frame.
    # Parameters: pFile = The address of the gale object.
    # Return:     If the function succeeds, the return value is number of frame.
    #             If the function fails, the return value is 0.
    attach_function :frame_count, :ggGetFrameCount, [:pointer], :uint

    # DWORD __stdcall ggGetLayerCount(LPVOID pFile,LONG frameNo);
    # Contents:   Retrieves number of layer.
    # Parameters: pFile = The address of the gale object.
    # frameNo = The frame index which begin from zero.
    # Return:     If the function succeeds, the return value is number of
    #             layer of specified frame.
    #             If the function fails, the return value is 0.
    attach_function :layer_count, :ggGetLayerCount, [:pointer, :long], :uint

    # LONG __stdcall ggGetInfo(LPVOID pFile,LONG nID);
    # Contents:   Retrieves information of gale object.
    # Parameters: pFile = The address of the gale object.
    #             nID = Specifies information ID.
    # 1 = Return value is background-color.
    # 2 = If the palette is single, return value is 1.
    # 3 = If the transparency of bottom layer is disabled,
    #    return value is 1.
    # 4 = Return value is bpp(1,4,8,15,16,24).
    # 5 = Return value is width of image by pixel.
    # 6 = Return value is height of image by pixel.
    # Return:     See the Parameters.
    attach_function :info, :ggGetInfo, [:pointer, :long], :long

    # LONG __stdcall ggGetFrameInfo(LPVOID pFile,LONG frameNo,LONG nID);
    # Contents:   Retrieves information of specified frame.
    # Parameters: pFile = The address of the gale object.
    # frameNo = The frame index which begin from zero.
    # nID = Specifies information ID.
    # 1 = Return value is the transparent color.
    # 2 = Return value is the delay by milli-second.
    # 3 = Return value is the disposal type after display.
    #   0 = Not specified.
    #   1 = Not disposed.
    #   2 = Filled by the background-color.
    #   3 = Restored to previous state.
    # Return:     See the Parameters.
    attach_function :frame_info, :ggGetFrameInfo, [:pointer, :long, :long], :long

    # LONG __stdcall ggGetFrameName(LPVOID pFile,LONG frameNo,LPSTR pName,LONG len);
    # Contents:   Retrieves the name of specified frame.
    # Parameters: pFile = The address of the gale object.
    #             frameNo = The frame index which begin from zero.
    #             pName = The address of string buffer that receives the
    #                     null-terminated string specifying the name.
    #                     If it is NULL, return value is necessary size of
    #                     buffer.
    #             len = Specifies the size in byte of the buffer.
    # Return: If the function succeeds, the return value is the length in
    #         byte, of the string copied to pName.
    #         If the function fails, the return value is 0.
    attach_function :frame_name, :ggGetFrameName, [:pointer, :long, :buffer_out, :long], :long

    # LONG __stdcall ggGetLayerInfo(LPVOID pFile,LONG frameNo,LONG layerNo,LONG nID);
    # Contents:   Retrieves information of specified layer.
    # Parameters: pFile = The address of the gale object.
    #             frameNo = The frame index which begin from zero.
    #             layerNo = The layer index which begin from zero.
    #             nID = Specifies information ID.
    #                   1 = If the layer is visible, return value is 1.
    #                   2 = Return value is the transparent color.
    #                   3 = Return value is the opacity(0~255).
    #                   4 = If the alpha-channel is effective, return value is 1
    # Return:     See the Parameters.
    attach_function :layer_info, :ggGetLayerInfo, [:pointer, :long, :long, :long], :long

    # LONG __stdcall ggGetLayerName(LPVOID pFile,LONG frameNo,LONG layerNo,LPSTR pName,LONG len);
    # Contents:   Retrieves the name of specified layer.
    # Parameters: pFile = The address of the gale object.
    #             frameNo = The frame index which begin from zero.
    #             layerNo = The layer index which begin from zero.
    #             pName = The address of string buffer that receives the
    #                     null-terminated string specifying the name.
    #                     If it is NULL, return value is necessary size of
    #                     buffer.
    #            len = Specifies the size in byte of the buffer.
    # Return:     If the function succeeds, the return value is the length in
    #             byte, of the string copied to pName.
    #             If the function fails, the return value is 0.
    attach_function :layer_name, :ggGetLayerName, [:pointer, :long, :long, :buffer_out, :long], :long

    # HBITMAP __stdcall ggGetBitmap(LPVOID pFile,LONG frameNo,LONG layerNo);
    # Contents:   Retrieves the handle of bitmap of specified frame and
    #            layer. The handle must not be deleted.
    #  Parameters: pFile = The address of the gale object.
    #              frameNo = The frame index which begin from zero.
    #              layerNo = The layer index which begin from zero.
    #                        If it is -1, combined image is retrieved.
    # Return:     If the function succeeds, the return value is the handle of
    # bitmap.
    # If the function fails, the return value is 0.
    #attach_function :bitmap, :ggGetBitmap, [:pointer, :long, :long], :pointer


    #HBITMAP __stdcall ggGetAlphaChannel(LPVOID pFile,LONG frameNo,LONG layerNo);
    #  Contents:   Retrieves the handle of bitmap of alpha channel of specified
    #              frame and layer. The handle must not be deleted.
    #  Parameters: pFile = The address of the gale object.
    #              frameNo = The frame index which begin from zero.
    #              layerNo = The layer index which begin from zero.
    #  Return:     If the function succeeds, the return value is the handle of
    #              bitmap.
    #              If the function fails, the return value is 0.
    #attach_function :alpha_channel, :ggGetAlphaChannel, [:pointer, :long, :long], :pointer


    #HPALETTE __stdcall ggGetPalette(LPVOID pFile,LONG frameNo);
    #  Contents:   Retrieves the handle of palette of specified frame.
    #              The handle must not be deleted.
    #  Parameters: pFile = The address of the gale object.
    #              frameNo = The frame index which begin from zero.
    #  Return:     If the function succeeds, the return value is the handle of
    #              palette.
    #              If the function fails, the return value is 0.
    #attach_function :palette, :ggGetPalette, [:pointer, :long], :pointer


    #LONG __stdcall ggDrawBitmap(LPVOID pFile,LONG frameNo,LONG layerNo,HDC toDC,LONG toX,LONG toY);
    #  Contents:   Draws the image of specified frame and layer to specified
    #              device context.
    #  Parameters: pFile = The address of the gale object.
    #              frameNo = The frame index which begin from zero.
    #              layerNo = The layer index which begin from zero.
    #                        If it is -1, combined image is retrieved.
    #              toDC = The handle of device context of the destination.
    #              toX = Specifies the x-coordinate of the destination.
    #              toY = Specifies the y-coordinate of the destination.
    #  Return:     If the function succeeds, the return value is 1.
    #              If the function fails, the return value is 0.

    #LONG __stdcall ggExportBitmap(LPVOID pFile,LONG frameNo,LONG layerNo,LPCSTR outPath);
    #  Contents:   Creates a bmp file from the image of specified frame and
    #              layer.
    #  Parameters: pFile = The address of the gale object.
    #              frameNo = The frame index which begin from zero.
    #              layerNo = The layer index which begin from zero.
    #                        If it is -1, combined image is created.
    #              outPath = The filename for output.
    #  Return:     If the function succeeds, the return value is 1.
    #              If the function fails, the return value is 0.
    attach_function :export_bitmap, :ggExportBitmap, [:pointer, :long, :long, :string], :long
    

    #LONG __stdcall ggExportAlphaChannel(LPVOID pFile,LONG frameNo,LONG layerNo,LPCSTR outPath);
    #  Contents:   Creates a bmp file from the alpha channel of specified frame
    #              and layer.
    #  Parameters: pFile = The address of the gale object.
    #              frameNo = The frame index which begin from zero.
    #              layerNo = The layer index which begin from zero.
    #              outPath = The filename for output.
    #  Return:     If the function succeeds, the return value is 1.
    #              If the function fails, the return value is 0.
    attach_function :export_alpha_channel, :ggExportAlphaChannel, [:pointer, :long, :long, :string], :long
  end
end
