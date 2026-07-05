import { z } from 'zod';

// Uses base schemas (ZodObject) — discriminatedUnion requires ZodObject, not ZodEffects
export const eventSchema = z.object({
  webhookUrl: z.url(),
  data: z.object({})
});

export type EventInput = z.infer<typeof eventSchema>;
