import { RewriteFrames } from '@sentry/integrations'
import * as Sentry from '@sentry/serverless'
Sentry.AWSLambda.init({
  dsn: process.env.SENTRY_DSN,
  release: process.env.SENTRY_RELEASE,
  tracesSampleRate: 1.0,
  integrations: [
    new RewriteFrames({
      root: process.cwd(),
    }),
  ],
})
export const handler = Sentry.AWSLambda.wrapHandler(async (event: any) => {
  Sentry.addBreadcrumb({
    category: 'parseTextFromScispaCy',
    data: {
      event: event,
    }
  })
  console.log(`EVENT=>`, JSON.stringify(event, null, 2))
  if(event?.type === 'error') {
    throw new Error('This is a test error')
  }
  return {
    statusCode: 200,
    test: 'hello world',
  }
})
