set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.post_message_reaction(message_id uuid, reaction text, mode text)
 RETURNS void
 LANGUAGE plv8
 SECURITY DEFINER
AS $function$

const { user_id, group_id, role, message_group_id, reactions } = plv8.execute('SELECT auth.uid() AS user_id, group_id_for(auth.uid()) AS group_id, role_for(auth.uid()) AS role, m.group_id AS message_group_id, m.reactions as reactions FROM messages m WHERE id=$1 LIMIT 1', [message_id])[0]

if (group_id !== message_group_id && role !== 'operator' && role !== 'admin') return

if (mode === 'remove') {
  reactions[reaction] = (reactions[reaction] || []).filter(u => u !== user_id)
} else {
  reactions[reaction] = (reactions[reaction] || []).concat([user_id])
}

plv8.execute('UPDATE messages SET reactions=$1 WHERE id=$2', [reactions, message_id])

plv8.execute('SELECT increment_unseen_counter($1, 1)', [message_group_id])
$function$
;

