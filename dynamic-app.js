import { format } from 'date-fns';
import { execa } from 'execa';
import amplifyE2EApi from './node_modules/amplify-cli/packages/amplify-e2e-core/src/categories/api.ts';
const { addApiWithThreeModels } = amplifyE2EApi;

const dateStr = format(new Date(), 'yyyyMMddhhmm')
console.log({dateStr})
const projectDir=`${dateStr}-amplify-cli-cra-multiauth`


async function main() {
    execa('npx', ['create-react-app@latest', projectDir]).stdout.pipe(process.stdout);
    execa('cd', [projectDir])
    await addApiWithThreeModels(projectDir)
}

main()
