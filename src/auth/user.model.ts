export interface User {
    id: number;
    username: string;
    role: 'Administrator' | 'Reader' | 'Requestor' | 'Editor';
}
