export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      acceso_rol: {
        Row: {
          codigo_acceso: string
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          rol_id: string
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          codigo_acceso: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          rol_id: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          codigo_acceso?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          rol_id?: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "acceso_roles_rol_id_fkey"
            columns: ["rol_id"]
            isOneToOne: false
            referencedRelation: "rol"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "acceso_roles_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      assistant_intent_catalog: {
        Row: {
          active: boolean | null
          category: string
          created_at: string | null
          description: string
          display_name: string
          empresa_id: string | null
          id: string
          requires_cash_open: boolean | null
          requires_permissions: string[] | null
          requires_warehouse: boolean | null
          workflow_id: string
        }
        Insert: {
          active?: boolean | null
          category: string
          created_at?: string | null
          description: string
          display_name: string
          empresa_id?: string | null
          id: string
          requires_cash_open?: boolean | null
          requires_permissions?: string[] | null
          requires_warehouse?: boolean | null
          workflow_id: string
        }
        Update: {
          active?: boolean | null
          category?: string
          created_at?: string | null
          description?: string
          display_name?: string
          empresa_id?: string | null
          id?: string
          requires_cash_open?: boolean | null
          requires_permissions?: string[] | null
          requires_warehouse?: boolean | null
          workflow_id?: string
        }
        Relationships: []
      }
      assistant_tools_catalog: {
        Row: {
          active: boolean | null
          category: string
          description: string
          id: string
          input_schema: Json
          output_schema: Json
        }
        Insert: {
          active?: boolean | null
          category: string
          description: string
          id: string
          input_schema: Json
          output_schema: Json
        }
        Update: {
          active?: boolean | null
          category?: string
          description?: string
          id?: string
          input_schema?: Json
          output_schema?: Json
        }
        Relationships: []
      }
      assistant_workflows: {
        Row: {
          active: boolean | null
          definition: Json
          descripcion: string | null
          id: string
          nombre: string
          updated_at: string | null
          version: number | null
        }
        Insert: {
          active?: boolean | null
          definition: Json
          descripcion?: string | null
          id: string
          nombre: string
          updated_at?: string | null
          version?: number | null
        }
        Update: {
          active?: boolean | null
          definition?: Json
          descripcion?: string | null
          id?: string
          nombre?: string
          updated_at?: string | null
          version?: number | null
        }
        Relationships: []
      }
      bodega: {
        Row: {
          descripcion: string | null
          direccion: string | null
          empresa_id: string
          es_punto_venta: boolean | null
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          nombre: string
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          descripcion?: string | null
          direccion?: string | null
          empresa_id: string
          es_punto_venta?: boolean | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          descripcion?: string | null
          direccion?: string | null
          empresa_id?: string
          es_punto_venta?: boolean | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre?: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bodegas_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bodegas_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      bodega_usuario: {
        Row: {
          bodega_id: string
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_id: string
          usuario_registro_id: string | null
        }
        Insert: {
          bodega_id: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_id: string
          usuario_registro_id?: string | null
        }
        Update: {
          bodega_id?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_id?: string
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bodega_usuario_bodega_id_fkey"
            columns: ["bodega_id"]
            isOneToOne: false
            referencedRelation: "bodega"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bodega_usuario_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bodega_usuario_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      caja: {
        Row: {
          bodega_id: string | null
          empresa_id: string
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          nombre: string
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          bodega_id?: string | null
          empresa_id: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          bodega_id?: string | null
          empresa_id?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre?: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "cajas_bodega_id_fkey"
            columns: ["bodega_id"]
            isOneToOne: false
            referencedRelation: "bodega"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cajas_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cajas_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      caja_movimiento_extra: {
        Row: {
          caja_sesion_id: string
          estado: boolean | null
          fecha_eliminacion: string | null
          id: string
          monto: number
          motivo: string | null
          referencia_venta_id: string | null
          server_updated_at: string
          tipo: Database["public"]["Enums"]["tipo_movimiento_caja_enum"]
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          caja_sesion_id: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          id?: string
          monto: number
          motivo?: string | null
          referencia_venta_id?: string | null
          server_updated_at?: string
          tipo: Database["public"]["Enums"]["tipo_movimiento_caja_enum"]
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          caja_sesion_id?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          id?: string
          monto?: number
          motivo?: string | null
          referencia_venta_id?: string | null
          server_updated_at?: string
          tipo?: Database["public"]["Enums"]["tipo_movimiento_caja_enum"]
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "caja_movimientos_extra_caja_sesion_id_fkey"
            columns: ["caja_sesion_id"]
            isOneToOne: false
            referencedRelation: "caja_sesion"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "caja_movimientos_extra_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      caja_sesion: {
        Row: {
          caja_id: string
          diferencia: number | null
          estado_sesion:
            | Database["public"]["Enums"]["estado_sesion_enum"]
            | null
          fecha_apertura: string | null
          fecha_cierre: string | null
          fecha_eliminacion: string | null
          id: string
          monto_inicial: number | null
          server_updated_at: string
          total_efectivo_real: number | null
          total_ventas_sistema: number | null
          ultima_actualizacion: string | null
          usuario_apertura_id: string
          usuario_cierre_id: string | null
        }
        Insert: {
          caja_id: string
          diferencia?: number | null
          estado_sesion?:
            | Database["public"]["Enums"]["estado_sesion_enum"]
            | null
          fecha_apertura?: string | null
          fecha_cierre?: string | null
          fecha_eliminacion?: string | null
          id?: string
          monto_inicial?: number | null
          server_updated_at?: string
          total_efectivo_real?: number | null
          total_ventas_sistema?: number | null
          ultima_actualizacion?: string | null
          usuario_apertura_id: string
          usuario_cierre_id?: string | null
        }
        Update: {
          caja_id?: string
          diferencia?: number | null
          estado_sesion?:
            | Database["public"]["Enums"]["estado_sesion_enum"]
            | null
          fecha_apertura?: string | null
          fecha_cierre?: string | null
          fecha_eliminacion?: string | null
          id?: string
          monto_inicial?: number | null
          server_updated_at?: string
          total_efectivo_real?: number | null
          total_ventas_sistema?: number | null
          ultima_actualizacion?: string | null
          usuario_apertura_id?: string
          usuario_cierre_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "caja_sesiones_caja_id_fkey"
            columns: ["caja_id"]
            isOneToOne: false
            referencedRelation: "caja"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "caja_sesiones_usuario_apertura_id_fkey"
            columns: ["usuario_apertura_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "caja_sesiones_usuario_cierre_id_fkey"
            columns: ["usuario_cierre_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      cargo_adicional: {
        Row: {
          aplicar_automatico: boolean | null
          empresa_id: string | null
          es_porcentaje: boolean | null
          id: string
          nombre: string | null
          ultima_actualizacion: string | null
          valor: number | null
        }
        Insert: {
          aplicar_automatico?: boolean | null
          empresa_id?: string | null
          es_porcentaje?: boolean | null
          id?: string
          nombre?: string | null
          ultima_actualizacion?: string | null
          valor?: number | null
        }
        Update: {
          aplicar_automatico?: boolean | null
          empresa_id?: string | null
          es_porcentaje?: boolean | null
          id?: string
          nombre?: string | null
          ultima_actualizacion?: string | null
          valor?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "cargos_adicionales_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
        ]
      }
      categoria: {
        Row: {
          categoria_padre_id: string | null
          empresa_id: string
          especificacion: Json | null
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          nombre: string
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          categoria_padre_id?: string | null
          empresa_id: string
          especificacion?: Json | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          categoria_padre_id?: string | null
          empresa_id?: string
          especificacion?: Json | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre?: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "categorias_categoria_padre_id_fkey"
            columns: ["categoria_padre_id"]
            isOneToOne: false
            referencedRelation: "categoria"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "categorias_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "categorias_registro_usuario_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      cliente: {
        Row: {
          celular: string | null
          direccion: string | null
          empresa_id: string
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          identificacion: string | null
          monto_credito_maximo: number | null
          nombre: string
          saldo_deudor_actual: number | null
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          celular?: string | null
          direccion?: string | null
          empresa_id: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          identificacion?: string | null
          monto_credito_maximo?: number | null
          nombre: string
          saldo_deudor_actual?: number | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          celular?: string | null
          direccion?: string | null
          empresa_id?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          identificacion?: string | null
          monto_credito_maximo?: number | null
          nombre?: string
          saldo_deudor_actual?: number | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "clientes_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "clientes_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      codigo_producto: {
        Row: {
          codigo_sku: string
          color: string | null
          costo_especifico: number | null
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          precio_especifico: number | null
          producto_id: string
          server_updated_at: string
          talla: string | null
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          codigo_sku: string
          color?: string | null
          costo_especifico?: number | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          precio_especifico?: number | null
          producto_id: string
          server_updated_at?: string
          talla?: string | null
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          codigo_sku?: string
          color?: string | null
          costo_especifico?: number | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          precio_especifico?: number | null
          producto_id?: string
          server_updated_at?: string
          talla?: string | null
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "codigo_producto_producto_id_fkey"
            columns: ["producto_id"]
            isOneToOne: false
            referencedRelation: "producto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "codigo_producto_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      debug_logs: {
        Row: {
          action: string | null
          android_version: string | null
          app_version_code: number | null
          app_version_name: string | null
          bodega_id: string | null
          build_number: string | null
          created_at: string
          device_model: string | null
          empresa_id: string | null
          error_code: string | null
          id: string
          is_online: boolean | null
          level: string
          message: string
          metadata_json: Json | null
          module: string | null
          received_at: string
          resolved: boolean
          resolved_at: string | null
          screen: string | null
          user_id: string | null
        }
        Insert: {
          action?: string | null
          android_version?: string | null
          app_version_code?: number | null
          app_version_name?: string | null
          bodega_id?: string | null
          build_number?: string | null
          created_at: string
          device_model?: string | null
          empresa_id?: string | null
          error_code?: string | null
          id: string
          is_online?: boolean | null
          level: string
          message: string
          metadata_json?: Json | null
          module?: string | null
          received_at?: string
          resolved?: boolean
          resolved_at?: string | null
          screen?: string | null
          user_id?: string | null
        }
        Update: {
          action?: string | null
          android_version?: string | null
          app_version_code?: number | null
          app_version_name?: string | null
          bodega_id?: string | null
          build_number?: string | null
          created_at?: string
          device_model?: string | null
          empresa_id?: string | null
          error_code?: string | null
          id?: string
          is_online?: boolean | null
          level?: string
          message?: string
          metadata_json?: Json | null
          module?: string | null
          received_at?: string
          resolved?: boolean
          resolved_at?: string | null
          screen?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      detalle_movimiento_producto: {
        Row: {
          cantidad: number
          cargos_adicionales: Json | null
          costo_proveedor: number | null
          costo_unitario_final: number | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          movimiento_producto_id: string
          producto_id: string
          producto_variante_id: string | null
          server_updated_at: string
          ultima_actualizacion: string | null
          variantes_json: string | null
        }
        Insert: {
          cantidad: number
          cargos_adicionales?: Json | null
          costo_proveedor?: number | null
          costo_unitario_final?: number | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          movimiento_producto_id: string
          producto_id: string
          producto_variante_id?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          variantes_json?: string | null
        }
        Update: {
          cantidad?: number
          cargos_adicionales?: Json | null
          costo_proveedor?: number | null
          costo_unitario_final?: number | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          movimiento_producto_id?: string
          producto_id?: string
          producto_variante_id?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          variantes_json?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "detalle_movimiento_producto_producto_variante_id_fkey"
            columns: ["producto_variante_id"]
            isOneToOne: false
            referencedRelation: "codigo_producto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "detalle_movimiento_productos_movimiento_producto_id_fkey"
            columns: ["movimiento_producto_id"]
            isOneToOne: false
            referencedRelation: "movimiento_producto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "detalle_movimiento_productos_producto_id_fkey"
            columns: ["producto_id"]
            isOneToOne: false
            referencedRelation: "producto"
            referencedColumns: ["id"]
          },
        ]
      }
      detalle_venta: {
        Row: {
          cantidad: number
          costo_historico_compra: number | null
          descuento: number | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          precio_unitario: number
          producto_id: string
          producto_variante_id: string | null
          server_updated_at: string
          sub_total: number
          ultima_actualizacion: string | null
          venta_id: string
        }
        Insert: {
          cantidad: number
          costo_historico_compra?: number | null
          descuento?: number | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          precio_unitario: number
          producto_id: string
          producto_variante_id?: string | null
          server_updated_at?: string
          sub_total: number
          ultima_actualizacion?: string | null
          venta_id: string
        }
        Update: {
          cantidad?: number
          costo_historico_compra?: number | null
          descuento?: number | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          precio_unitario?: number
          producto_id?: string
          producto_variante_id?: string | null
          server_updated_at?: string
          sub_total?: number
          ultima_actualizacion?: string | null
          venta_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "detalle_venta_producto_variante_id_fkey"
            columns: ["producto_variante_id"]
            isOneToOne: false
            referencedRelation: "codigo_producto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "detalle_ventas_producto_id_fkey"
            columns: ["producto_id"]
            isOneToOne: false
            referencedRelation: "producto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "detalle_ventas_venta_id_fkey"
            columns: ["venta_id"]
            isOneToOne: false
            referencedRelation: "venta_producto"
            referencedColumns: ["id"]
          },
        ]
      }
      empresa: {
        Row: {
          configuracion: Json | null
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          nombre: string
          nombre_comercial: string | null
          ruc: string | null
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          configuracion?: Json | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre: string
          nombre_comercial?: string | null
          ruc?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          configuracion?: Json | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre?: string
          nombre_comercial?: string | null
          ruc?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: []
      }
      historial_pago: {
        Row: {
          caja_sesion_id: string
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          fecha_registro_pago: string | null
          id: string
          metodo_de_pago: Database["public"]["Enums"]["metodo_pago_enum"]
          monto_pagado: number
          referencia: string | null
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
          venta_id: string
        }
        Insert: {
          caja_sesion_id: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          fecha_registro_pago?: string | null
          id?: string
          metodo_de_pago: Database["public"]["Enums"]["metodo_pago_enum"]
          monto_pagado: number
          referencia?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
          venta_id: string
        }
        Update: {
          caja_sesion_id?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          fecha_registro_pago?: string | null
          id?: string
          metodo_de_pago?: Database["public"]["Enums"]["metodo_pago_enum"]
          monto_pagado?: number
          referencia?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
          venta_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "historial_pagos_caja_sesion_id_fkey"
            columns: ["caja_sesion_id"]
            isOneToOne: false
            referencedRelation: "caja_sesion"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "historial_pagos_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "historial_pagos_venta_id_fkey"
            columns: ["venta_id"]
            isOneToOne: false
            referencedRelation: "venta_producto"
            referencedColumns: ["id"]
          },
        ]
      }
      inventario_codigo_producto: {
        Row: {
          cantidad: number | null
          codigo_producto_id: string
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          inventario_id: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          cantidad?: number | null
          codigo_producto_id: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          inventario_id: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          cantidad?: number | null
          codigo_producto_id?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          inventario_id?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "inventario_codigo_producto_codigo_producto_id_fkey"
            columns: ["codigo_producto_id"]
            isOneToOne: false
            referencedRelation: "codigo_producto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventario_codigo_producto_inventario_id_fkey"
            columns: ["inventario_id"]
            isOneToOne: false
            referencedRelation: "inventario_producto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventario_codigo_producto_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      inventario_producto: {
        Row: {
          actualizado_por: string | null
          bodega_id: string
          cantidad_actual: number | null
          cantidad_reservada: number | null
          costo_promedio: number | null
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          precio_venta: number | null
          producto_id: string
          producto_variante_id: string | null
          server_updated_at: string
          ubicacion_pasillo: string | null
          ultima_actualizacion: string | null
        }
        Insert: {
          actualizado_por?: string | null
          bodega_id: string
          cantidad_actual?: number | null
          cantidad_reservada?: number | null
          costo_promedio?: number | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          precio_venta?: number | null
          producto_id: string
          producto_variante_id?: string | null
          server_updated_at?: string
          ubicacion_pasillo?: string | null
          ultima_actualizacion?: string | null
        }
        Update: {
          actualizado_por?: string | null
          bodega_id?: string
          cantidad_actual?: number | null
          cantidad_reservada?: number | null
          costo_promedio?: number | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          precio_venta?: number | null
          producto_id?: string
          producto_variante_id?: string | null
          server_updated_at?: string
          ubicacion_pasillo?: string | null
          ultima_actualizacion?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "inventario_producto_producto_variante_id_fkey"
            columns: ["producto_variante_id"]
            isOneToOne: false
            referencedRelation: "codigo_producto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventario_productos_actualizado_por_fkey"
            columns: ["actualizado_por"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventario_productos_bodega_id_fkey"
            columns: ["bodega_id"]
            isOneToOne: false
            referencedRelation: "bodega"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventario_productos_producto_id_fkey"
            columns: ["producto_id"]
            isOneToOne: false
            referencedRelation: "producto"
            referencedColumns: ["id"]
          },
        ]
      }
      movimiento_producto: {
        Row: {
          bodega_destino_id: string | null
          bodega_origen_id: string | null
          descripcion: string | null
          empresa_id: string
          estado: boolean | null
          estado_movimiento:
            | Database["public"]["Enums"]["estado_movimiento_enum"]
            | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          server_updated_at: string
          tipo_movimiento: Database["public"]["Enums"]["tipo_movimiento_enum"]
          tipo_movimiento_local: string | null
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          bodega_destino_id?: string | null
          bodega_origen_id?: string | null
          descripcion?: string | null
          empresa_id: string
          estado?: boolean | null
          estado_movimiento?:
            | Database["public"]["Enums"]["estado_movimiento_enum"]
            | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          server_updated_at?: string
          tipo_movimiento: Database["public"]["Enums"]["tipo_movimiento_enum"]
          tipo_movimiento_local?: string | null
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          bodega_destino_id?: string | null
          bodega_origen_id?: string | null
          descripcion?: string | null
          empresa_id?: string
          estado?: boolean | null
          estado_movimiento?:
            | Database["public"]["Enums"]["estado_movimiento_enum"]
            | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          server_updated_at?: string
          tipo_movimiento?: Database["public"]["Enums"]["tipo_movimiento_enum"]
          tipo_movimiento_local?: string | null
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "movimiento_productos_bodega_destino_id_fkey"
            columns: ["bodega_destino_id"]
            isOneToOne: false
            referencedRelation: "bodega"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "movimiento_productos_bodega_origen_id_fkey"
            columns: ["bodega_origen_id"]
            isOneToOne: false
            referencedRelation: "bodega"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "movimiento_productos_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "movimiento_productos_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      producto: {
        Row: {
          categoria_id: string | null
          codigo_personalizado: string | null
          descripcion: string | null
          empresa_id: string
          especificacion: Json | null
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          imagen_url: string | null
          nombre: string
          precio_base: number | null
          registro_usuario_id: string | null
          server_updated_at: string
          ultima_actualizacion: string | null
          ultimo_costo: number | null
          ultimo_precio_venta: number | null
        }
        Insert: {
          categoria_id?: string | null
          codigo_personalizado?: string | null
          descripcion?: string | null
          empresa_id: string
          especificacion?: Json | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          imagen_url?: string | null
          nombre: string
          precio_base?: number | null
          registro_usuario_id?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          ultimo_costo?: number | null
          ultimo_precio_venta?: number | null
        }
        Update: {
          categoria_id?: string | null
          codigo_personalizado?: string | null
          descripcion?: string | null
          empresa_id?: string
          especificacion?: Json | null
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          imagen_url?: string | null
          nombre?: string
          precio_base?: number | null
          registro_usuario_id?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          ultimo_costo?: number | null
          ultimo_precio_venta?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "productos_categoria_id_fkey"
            columns: ["categoria_id"]
            isOneToOne: false
            referencedRelation: "categoria"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "productos_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "productos_registro_usuario_id_fkey"
            columns: ["registro_usuario_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
      regla_costo: {
        Row: {
          activo: boolean | null
          empresa_id: string | null
          factor_redondeo: number | null
          id: string
          nombre: string | null
          ultima_actualizacion: string | null
        }
        Insert: {
          activo?: boolean | null
          empresa_id?: string | null
          factor_redondeo?: number | null
          id?: string
          nombre?: string | null
          ultima_actualizacion?: string | null
        }
        Update: {
          activo?: boolean | null
          empresa_id?: string | null
          factor_redondeo?: number | null
          id?: string
          nombre?: string | null
          ultima_actualizacion?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "reglas_costos_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
        ]
      }
      rol: {
        Row: {
          empresa_id: string
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          nombre: string
          server_updated_at: string
          ultima_actualizacion: string | null
          user_admin: boolean | null
          usuario_registro_id: string | null
        }
        Insert: {
          empresa_id: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          user_admin?: boolean | null
          usuario_registro_id?: string | null
        }
        Update: {
          empresa_id?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre?: string
          server_updated_at?: string
          ultima_actualizacion?: string | null
          user_admin?: boolean | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "roles_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
        ]
      }
      usuario: {
        Row: {
          bodega_default_id: string | null
          correo: string | null
          empresa_id: string
          estado: boolean | null
          fecha_eliminacion: string | null
          fecha_registro: string | null
          id: string
          nombre_completo: string
          password_hash: string | null
          pin_offline: string | null
          rol_id: string | null
          server_updated_at: string
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          bodega_default_id?: string | null
          correo?: string | null
          empresa_id: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id: string
          nombre_completo: string
          password_hash?: string | null
          pin_offline?: string | null
          rol_id?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          bodega_default_id?: string | null
          correo?: string | null
          empresa_id?: string
          estado?: boolean | null
          fecha_eliminacion?: string | null
          fecha_registro?: string | null
          id?: string
          nombre_completo?: string
          password_hash?: string | null
          pin_offline?: string | null
          rol_id?: string | null
          server_updated_at?: string
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "usuario_bodega_default_id_fkey"
            columns: ["bodega_default_id"]
            isOneToOne: false
            referencedRelation: "bodega"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "usuarios_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "usuarios_rol_id_fkey"
            columns: ["rol_id"]
            isOneToOne: false
            referencedRelation: "rol"
            referencedColumns: ["id"]
          },
        ]
      }
      venta_producto: {
        Row: {
          caja_sesion_id: string
          cliente_id: string
          empresa_id: string
          estado: boolean | null
          estado_pago: Database["public"]["Enums"]["estado_pago_enum"] | null
          fecha_eliminacion: string | null
          fecha_vencimiento: string | null
          fecha_venta: string | null
          id: string
          saldo_pendiente: number | null
          server_updated_at: string
          tipo_venta: Database["public"]["Enums"]["tipo_venta_enum"]
          total_pagado: number | null
          total_venta: number
          ultima_actualizacion: string | null
          usuario_registro_id: string | null
        }
        Insert: {
          caja_sesion_id: string
          cliente_id: string
          empresa_id: string
          estado?: boolean | null
          estado_pago?: Database["public"]["Enums"]["estado_pago_enum"] | null
          fecha_eliminacion?: string | null
          fecha_vencimiento?: string | null
          fecha_venta?: string | null
          id?: string
          saldo_pendiente?: number | null
          server_updated_at?: string
          tipo_venta: Database["public"]["Enums"]["tipo_venta_enum"]
          total_pagado?: number | null
          total_venta?: number
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Update: {
          caja_sesion_id?: string
          cliente_id?: string
          empresa_id?: string
          estado?: boolean | null
          estado_pago?: Database["public"]["Enums"]["estado_pago_enum"] | null
          fecha_eliminacion?: string | null
          fecha_vencimiento?: string | null
          fecha_venta?: string | null
          id?: string
          saldo_pendiente?: number | null
          server_updated_at?: string
          tipo_venta?: Database["public"]["Enums"]["tipo_venta_enum"]
          total_pagado?: number | null
          total_venta?: number
          ultima_actualizacion?: string | null
          usuario_registro_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "venta_productos_caja_sesion_id_fkey"
            columns: ["caja_sesion_id"]
            isOneToOne: false
            referencedRelation: "caja_sesion"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "venta_productos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "cliente"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "venta_productos_empresa_id_fkey"
            columns: ["empresa_id"]
            isOneToOne: false
            referencedRelation: "empresa"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "venta_productos_usuario_registro_id_fkey"
            columns: ["usuario_registro_id"]
            isOneToOne: false
            referencedRelation: "usuario"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      crear_empresa_inicial: {
        Args: {
          p_nombre_empresa: string
          p_ruc_empresa: string
          p_user_email: string
          p_user_id: string
          p_user_nombre: string
          p_user_password: string
        }
        Returns: Json
      }
      get_mi_empresa_id: { Args: never; Returns: string }
      sync_staff_profile: {
        Args: {
          p_bodega_ids: string[]
          p_correo: string
          p_empresa_id: string
          p_nombre_completo: string
          p_password_hash: string
          p_rol_id: string
          p_user_id: string
          p_usuario_registro_id: string
        }
        Returns: Json
      }
    }
    Enums: {
      estado_movimiento_enum:
        | "pendiente"
        | "aprobado"
        | "rechazado"
        | "PENDIENTE"
        | "APROBADO"
        | "RECHAZADO"
      estado_pago_enum:
        | "pagado"
        | "pendiente"
        | "parcial"
        | "anulado"
        | "PAGADO"
        | "PENDIENTE"
        | "PARCIAL"
        | "ANULADO"
      estado_sesion_enum:
        | "abierta"
        | "cerrada"
        | "arqueada"
        | "ABIERTA"
        | "CERRADA"
        | "ARQUEADA"
      metodo_pago_enum:
        | "efectivo"
        | "tarjeta"
        | "transferencia"
        | "EFECTIVO"
        | "TARJETA"
        | "TRANSFERENCIA"
      tipo_movimiento_caja_enum: "ingreso" | "egreso" | "INGRESO" | "EGRESO"
      tipo_movimiento_enum:
        | "compra"
        | "traslado"
        | "ajuste"
        | "solicitud"
        | "COMPRA"
        | "TRASLADO"
        | "AJUSTE"
        | "SOLICITUD"
      tipo_venta_enum: "contado" | "credito" | "CONTADO" | "CREDITO"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      estado_movimiento_enum: [
        "pendiente",
        "aprobado",
        "rechazado",
        "PENDIENTE",
        "APROBADO",
        "RECHAZADO",
      ],
      estado_pago_enum: [
        "pagado",
        "pendiente",
        "parcial",
        "anulado",
        "PAGADO",
        "PENDIENTE",
        "PARCIAL",
        "ANULADO",
      ],
      estado_sesion_enum: [
        "abierta",
        "cerrada",
        "arqueada",
        "ABIERTA",
        "CERRADA",
        "ARQUEADA",
      ],
      metodo_pago_enum: [
        "efectivo",
        "tarjeta",
        "transferencia",
        "EFECTIVO",
        "TARJETA",
        "TRANSFERENCIA",
      ],
      tipo_movimiento_caja_enum: ["ingreso", "egreso", "INGRESO", "EGRESO"],
      tipo_movimiento_enum: [
        "compra",
        "traslado",
        "ajuste",
        "solicitud",
        "COMPRA",
        "TRASLADO",
        "AJUSTE",
        "SOLICITUD",
      ],
      tipo_venta_enum: ["contado", "credito", "CONTADO", "CREDITO"],
    },
  },
} as const
