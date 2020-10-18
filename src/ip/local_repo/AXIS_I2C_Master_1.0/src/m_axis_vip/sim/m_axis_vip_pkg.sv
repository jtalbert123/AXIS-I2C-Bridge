


///////////////////////////////////////////////////////////////////////////
//NOTE: This file has been automatically generated by Vivado.
///////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
package m_axis_vip_pkg;
import axi4stream_vip_pkg::*;
///////////////////////////////////////////////////////////////////////////
// These parameters are named after the component for use in your verification 
// environment.
///////////////////////////////////////////////////////////////////////////
      parameter m_axis_vip_VIP_INTERFACE_MODE     = 0;
      parameter m_axis_vip_VIP_SIGNAL_SET         = 8'b00010011;
      parameter m_axis_vip_VIP_DATA_WIDTH         = 8;
      parameter m_axis_vip_VIP_ID_WIDTH           = 0;
      parameter m_axis_vip_VIP_DEST_WIDTH         = 0;
      parameter m_axis_vip_VIP_USER_WIDTH         = 0;
      parameter m_axis_vip_VIP_USER_BITS_PER_BYTE = 0;
      parameter m_axis_vip_VIP_HAS_TREADY         = 1;
      parameter m_axis_vip_VIP_HAS_TSTRB          = 0;
      parameter m_axis_vip_VIP_HAS_TKEEP          = 0;
      parameter m_axis_vip_VIP_HAS_TLAST          = 1;
      parameter m_axis_vip_VIP_HAS_ACLKEN         = 0;
      parameter m_axis_vip_VIP_HAS_ARESETN        = 1;
///////////////////////////////////////////////////////////////////////////
typedef axi4stream_mst_agent #(m_axis_vip_VIP_SIGNAL_SET, 
                        m_axis_vip_VIP_DEST_WIDTH,
                        m_axis_vip_VIP_DATA_WIDTH,
                        m_axis_vip_VIP_ID_WIDTH,
                        m_axis_vip_VIP_USER_WIDTH, 
                        m_axis_vip_VIP_USER_BITS_PER_BYTE,
                        m_axis_vip_VIP_HAS_ARESETN) m_axis_vip_mst_t;
      
///////////////////////////////////////////////////////////////////////////
// How to start the verification component
///////////////////////////////////////////////////////////////////////////
//      m_axis_vip_mst_t  m_axis_vip_mst;
//      initial begin : START_m_axis_vip_MASTER
//        m_axis_vip_mst = new("m_axis_vip_mst", `m_axis_vip_PATH_TO_INTERFACE);
//        m_axis_vip_mst.start_master();
//      end



endpackage : m_axis_vip_pkg
