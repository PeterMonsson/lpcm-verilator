package lpcm_pkg;

   typedef struct packed {
      int        latency;
      int        sample;
   } lpcm_item;

   function string convert2string(lpcm_item item);
      return $sformatf("sample=0x%0h latency=%0d", item.sample, item.latency);
   endfunction
   
endpackage
