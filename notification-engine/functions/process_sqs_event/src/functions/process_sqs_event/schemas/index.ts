import { z } from 'zod';

// Uses base schemas (ZodObject) — discriminatedUnion requires ZodObject, not ZodEffects
export const eventSchema = z.object({
  webhookUrl: z.url(),
  data: z.object({
    message: z
      .string()
      .min(1, { message: 'Message cannot be empty' })
      .max(500, { message: 'Message cannot exceed 500 characters' })
  })
});

export type EventInput = z.infer<typeof eventSchema>;
