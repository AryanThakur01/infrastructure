import { z } from 'zod';

// Uses base schemas (ZodObject) — discriminatedUnion requires ZodObject, not ZodEffects
export const eventSchema = z.object({
  email: z.email()
});

export type EventInput = z.infer<typeof eventSchema>;
