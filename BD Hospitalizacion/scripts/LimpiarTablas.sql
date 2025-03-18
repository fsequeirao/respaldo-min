


select *
from hospitalario.SNH_REL_ADMSRV_CAMAS;

-- Se borran camas asignadas a pacientes.

delete hospitalario.SNH_REL_ADMSRV_CAMAS;

--- Luego se tiene que borrar registros ingresos y egresos para luego borrar admision servicio.

-- Para hacer esto se hace un select de ingresos y egresos los valores de admision servicio id. Estos valores 
-- se dejan en el where del delete de admision servicio id para saber que registros borraremos.
-- no se deja de forma automatica porque como primero borramos los registros de ingresos y egresos,
-- luego no tendriamos los admision servicio id a borrar.

select *
 from hospitalario.snh_mst_ingresos_egresos b;   -- se obtienen los admision servicio id

-- Se borran registros de ingresos y egresos.

delete hospitalario.snh_mst_ingresos_egresos; 


--- se borran los registros de admision servicio, con los id que anteriormente
--- habiamos identificado.

delete hospitalario.snh_mst_admision_servicios
where admision_servicio_id in (2938,
2917,
2918,
3021,
3023,
3027,
3058,
2789,
3018,
3026,
2785,
2788,
2862,
2863,
2864,
2901,
2922,
3077,
2841);

-------
------ Luego procedemos a borrar pre ingresos y admisiones.
------ Para esto, igual hacemos un select a la tabla pre ingreso para obtener los
------ valores de admision id que luego borraremos de mst admisiones.


select *
from hospitalario.snh_mst_preg_ingresos;  -- se obtienen los datos de admision id

-- se borran registros de pre ingresos.


delete from hospitalario.snh_mst_preg_ingresos;

--- Luego se prodecemos a borrar los registros de mst admision con los id que copiamos
-- de la tabla pre ingreso.


delete hospitalario.snh_mst_admisiones
where admision_id in (2743,
2791,
2896,
2897,
2951,
2689,
2723,
2524,
2766,
2767,
2764,
2765,
2768,
2769,
2812,
2893,
2895,
2687,
2686,
2688,
2703,
2724,
2771,
2796,
2763)
          
